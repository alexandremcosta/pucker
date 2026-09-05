# Research: State of the Art for Multiplayer No-Limit Texas Hold'em

Purpose of this document: ground the next planning phase (implementing a SOTA-inspired
player in pucker and comparing it against the existing Bayesian-network / neural-net /
"RL" players) in (1) an honest account of what pucker's engine and players currently do,
and (2) the actual research landscape for multiplayer NLHE AI, so the plan is built on
facts rather than assumptions. No implementation decisions are made here.

## 1. What pucker actually is today

pucker is a ~2015-era JRuby thesis project (`doc/tex/thesis.pdf`, PUC coursework). It is
useful as a hand-evaluation/simulation harness, but its "No Limit Hold'em" is a
significantly simplified home-brew variant, and its "AI" players predate every technique
described in section 2. Concretely:

- **Fixed 5 players, hardcoded into the schema.** `NUM_PLAYERS = 5` (`lib/pucker.rb:13`),
  and `Pucker::State` has literal `player1_amount`..`player5_amount` /
  `player1_raises`..`player5_raises` columns (`lib/pucker/state.rb`). `PlayerGroup`
  hardcodes a 5-element container (`lib/pucker/player_group.rb`). Nothing here
  generalizes to N players without a schema/engine rewrite.
- **No preflop betting round.** `Game#play` (`lib/pucker/game.rb:22-42`) calls
  `collect_blinds`, immediately deals the flop, and only then starts `collect_bets`.
  There is no betting action between hole cards and the flop.
- **No small blind / big blind distinction.** `collect_blinds` takes a flat `BIG_BLIND`
  ante from *every* player, not a small blind from one seat and a big blind from the
  next. This diverges from standard NLHE structure that every solver/self-play method
  in section 2 assumes.
- **Bet sizing is not learned or abstracted, it's random.** `Player#raise_from`
  (`lib/pucker/players.rb:149-158`) raises a uniformly random `2.0..3.0x` of the min bet
  (or shoves all-in if the stack is short); "stochastic" fold/check/raise helpers mix in
  an 80-90% random-execution chance on top of whatever the strategy decided. There is no
  bet-size abstraction, no notion of an action-history, and only ever one active pot
  side-pot logic is fairly minimal.
- **The four player types:**
  - `Player` / `DummyPlayer` — always-check and uniform-random baselines.
  - `SimpleBnPlayer` / `BnPlayer` / `BestBnPlayer` (`lib/pucker/bn_players.rb`) — small
    hand-built Bayesian networks (via the `sbn` gem) with 2-3 discretized evidence
    variables (`hand_rank`, `min_bet`, `table_rank`/`position`) mapped to a handful of
    fixed if/else thresholds on `chance_to_win`. This is essentially a rule table with a
    probabilistic front end, not a learned strategy.
  - `NnPlayer{175,350,700,1000}` (`lib/pucker/nn_players.rb`) — a Ruby `Player` that
    makes a **synchronous HTTP POST per decision per action type** (fold/check/raise, so
    up to 3 blocking requests per decision point) to a Python service
    (`script/serve_predictions.py`) that wraps a regression model trained offline
    (`script/learn.py`) on logged `(state, decision, realized_reward)` rows to predict
    expected value of each action, then greedily argmaxes.
  - `RlPlayer` (`lib/pucker/rl_players.rb`) — despite the name, not RL in the modern
    sense (no policy/value network trained by self-play, no regret minimization). It's
    `NnPlayer700` plus a hand-rolled 1-ply Monte Carlo lookahead: it enumerates all
    possible next community cards, asks the NN service for a prediction on each
    resulting state, and averages. It is a heuristic search bolted onto the same
    regression network, not a distinct learning algorithm.
- **Numbers used for hand strength are already reasonable groundwork**: `Player#hand_potential`
  implements the classic Bill Chen/David Sklansky-style "hand strength / positive
  potential / negative potential" (HS, PPot, NPot) computation by brute-force enumeration
  over opponent hole-card combos and future run-outs (`lib/pucker/players.rb:171-226`),
  using a real Java hand evaluator (`lib/pucker/table/HandEvaluator.java`). That
  evaluator and the potential computation are reusable building blocks; nothing else is.
- **Persistence/serving path is a bottleneck by construction.** Every NN/RL decision is a
  blocking HTTP round trip to a single-process Flask/Manticore server on port 8082. This
  is fine for logging one hand at a time, but it cannot support the iteration volumes
  self-play/CFR-style training needs (see section 4) — those methods run in the
  hundreds of millions to trillions of game-tree traversals.

**Bottom line:** none of pucker's current players implement anything from the modern
poker-AI literature. They predate it. Comparing a new SOTA-inspired agent against them
is really "learned game-theoretic play vs. hand-tuned heuristics," which is a fine and
clear experiment, but the engine itself (fixed 5-seat schema, no preflop betting, flat
ante) will need real changes before a genuine multiplayer NLHE agent can be trained or
evaluated in it.

## 2. The poker AI research timeline

| Year | System | Players | Approach | Notes |
|---|---|---|---|---|
| 2017 | **Libratus** (CMU) | Heads-up (2p) | Blueprint via CFR + real-time nested subgame solving + self-improvement | First to beat top pros heads-up NLHE |
| 2017 | **DeepStack** (U. Alberta) | Heads-up | Continual re-solving + deep value networks (learned counterfactual values) replacing full-game abstraction | Beat pros heads-up; *Science* |
| 2018 | **AIVAT** (U. Alberta) | n/a (evaluation tool) | Variance-reduction estimator using nature's known chance outcomes + known-strategy opponents | Cuts hands needed for statistical significance by >10x; standard for AI-vs-human trials |
| 2019 | **Deep CFR / Single Deep CFR** (Brown, Sandholm et al.; Steinberger) | Any | Replace CFR's huge regret/strategy tables with neural nets trained on sampled traversals | Removes the need for hand-crafted card/action abstraction; open-sourced (`EricSteinberger/Deep-CFR`, `PokerRL`) |
| **2019** | **Pluribus** (Brown & Sandholm, Facebook AI Research + CMU) | **6-max multiplayer NLHE** | Self-play blueprint (Monte Carlo **Linear CFR**, minimal abstraction) + depth-limited real-time search during play, "safe" against arbitrary opponent adjustments | **Still the reference result for multiplayer NLHE.** Beat multiple pros simultaneously over 10k hands, both 5-humans-vs-1-Pluribus and 1-human-vs-5-Pluribus-copies. Trained in ~8 days on a 64-core CPU server, no GPU, reported cost ~\$150. *Science*, 2019. Source not released (Facebook chose not to, citing gambling-integrity concerns), but the paper + supplementary materials specify the algorithm in detail. |
| 2020 | **ReBeL** (Facebook AI Research) | Heads-up (demonstrated); general framework | Unifies self-play RL (a PBS/public-belief-state value+policy net) with real-time search; provably converges to Nash equilibrium in 2-player zero-sum games | General recipe, demonstrated on heads-up poker + Liar's Dice, not on multiplayer NLHE |
| 2022 | **AlphaHoldem** (Tsinghua, AAAI) | Heads-up | End-to-end model-free RL (pseudo-siamese actor-critic on card/action "images"), no abstraction, no search | Trains in ~3 days on a single GPU; fast but heads-up only |
| 2022 | **DecisionHoldem** | Heads-up | Safe depth-limited subgame solving + a diverse population of opponent models (instead of hand-designed abstraction) | Open-sourced; beat Slumbot and an open DeepStack reproduction ("OpenStack") by 700+ mbb/hand |
| 2023 | **Student of Games** (DeepMind + U. Alberta, *Science Advances*) | Chess/Go (perfect info) + heads-up poker + Scotland Yard (imperfect info) | Single unified algorithm: guided search + self-play + game-theoretic (regret-based) update, proven to converge to optimal play as compute grows | Beats the strongest open heads-up poker agent; not evaluated on multiplayer poker |
| 2024 | **PokerGPT** | Explicitly targets **arbitrary player counts** | Fine-tunes a small/lightweight LLM on textualized game logs (RLHF-style) instead of doing game-tree search | Framed as a cheap/fast alternative to CFR for multiplayer scaling; reported win-rate gains over baselines, but not benchmarked against Pluribus and not adopted/replicated as a new SOTA reference |
| 2025-2026 | **GTO Wizard AI benchmark** (`benchmark.gtowizard.com`) | Heads-up only today (200bb, Omega "coming soon") | Ongoing public leaderboard pitting frontier LLMs (GPT-5.x, Claude Opus 4.x, Gemini, Grok, Kimi) against a proprietary solver-grade heads-up agent | As of the current snapshot, no LLM has beaten the benchmark agent |
| 2026 | **PokerSkill** (arXiv 2605.30094) | Heads-up | LLM + deterministic "context engine" + human-authored skill library constraining actions, no solver/training | Reports the best LLM results yet (e.g., Claude Opus 4.6 at "only" ~-80±29 mbb/hand vs. the GTO Wizard benchmark agent) — still losing, but ~50-60% less than an unconstrained LLM baseline; beats Slumbot |

**Load-bearing conclusion:** essentially all algorithmic progress since Pluribus
(ReBeL, AlphaHoldem, DecisionHoldem, Student of Games, the LLM-based lines) has been
demonstrated on **heads-up** poker, where 2-player zero-sum guarantees (a well-defined
Nash equilibrium, safe subgame re-solving, provable convergence) hold. **Pluribus (2019)
remains the only published superhuman result specifically for multiplayer (3+) no-limit
Hold'em**, and nothing has publicly surpassed it on that specific problem as of this
research (Sept 2026). This is a real, still-open gap in the field, not just a gap in
pucker.

## 3. Why multiplayer NLHE is a fundamentally different (harder) problem

This is the single most important fact to carry into planning, because it changes what
"SOTA" even means here:

- In 2-player zero-sum games, a Nash equilibrium strategy has a **provable worst-case
  guarantee**: it cannot lose in expectation no matter what the opponent does. CFR,
  Deep CFR, ReBeL, safe subgame solving — all of that machinery's safety proofs lean on
  this two-player zero-sum structure.
- With **3+ players, that guarantee disappears**. Nash equilibria are not unique, are
  not exchangeable, computing one is not even known to be tractable, and playing "a"
  equilibrium strategy offers no guarantee against opponents who play a *different*
  equilibrium or who implicitly/explicitly coordinate against you (Brown & Sandholm,
  *Science* 2019, discuss this explicitly as their motivation for evaluating Pluribus
  empirically rather than theoretically).
- Pluribus's answer was pragmatic, not theoretical: run self-play (Monte Carlo Linear
  CFR) among *n* copies of itself to produce a strategy that is empirically very strong,
  then validate it the only way available for a 3+ player game — **play it against
  real, strong human opponents at scale** and measure win rate with variance-reduction
  (AIVAT-style) statistics, rather than compute exploitability against a
  worst-case opponent (which isn't well-defined/tractable at this scale anyway).
- Practically, this means: for a multiplayer NLHE agent, "how good is it" cannot be
  answered by an exploitability number the way it can heads-up. It has to be answered by
  **empirical match play** against a fixed, credible population of opponents (which,
  conveniently, is exactly what "compare it with pucker's existing players" already
  proposes) plus, ideally, against known strong reference bots (Slumbot-style, or humans)
  if multiplayer versions of those become available.

## 4. Core techniques worth knowing before planning (glossary)

- **CFR (Counterfactual Regret Minimization)** — iterative self-play algorithm that
  converges to a Nash equilibrium in 2-player zero-sum games by having each information
  set track "regret" for not having taken each action, and playing proportionally to
  positive regret. The base algorithm needs a full tabular game tree.
- **MCCFR (Monte Carlo CFR)** — samples parts of the tree per iteration instead of doing
  a full traversal, making CFR tractable on large games; this is the family Pluribus's
  training uses (specifically a "Linear CFR" variant that discounts early, noisier
  iterations).
- **Abstraction (action & information/card abstraction)** — because the full NLHE game
  tree is intractably large (raise sizes are continuous in principle, card combinations
  are huge), classical solvers bucket similar situations together (e.g., a handful of
  bet-size options instead of "any amount," clustering similar hands). Pluribus notably
  used a much *smaller* abstraction than earlier bots and made up the difference with
  real-time search — abstraction quality/coarseness is a direct design knob.
- **Deep CFR** — replaces the tabular regret/strategy storage with neural networks
  trained on sampled (state, action, regret) traversals, removing the need for
  hand-designed abstraction at the cost of needing a lot of self-play data and training
  infrastructure.
- **Blueprint + real-time (subgame) search** — train an approximate strategy offline
  ("blueprint"), then, live, re-solve just the remaining subgame more precisely given the
  actual situation (opponents' visible actions), which is far cheaper than solving the
  whole game to that precision offline. "Safe" search variants guarantee this can't make
  the strategy *more* exploitable than the blueprint alone.
- **Self-play** — training by having (copies of) the same policy play against itself,
  iteratively improving; this is how Pluribus, AlphaHoldem, and effectively all recent
  systems (and even pucker's `NnPlayer`s, in spirit, though via offline regression
  rather than iterative self-play) generate training data.
- **AIVAT** — an unbiased, low-variance estimator for agent performance in imperfect-info
  games, using known chance outcomes and known opponent strategies to strip out luck;
  used because raw win-rate variance in poker is enormous and would otherwise require
  huge sample sizes to draw a reliable conclusion.

## 5. Open-source building blocks available (so nothing needs to be built from scratch)

- **OpenSpiel** (`google-deepmind/open_spiel`) — includes CFR/MCCFR implementations and
  an ACPC-compatible "universal poker" game definition; the standard research sandbox
  for this class of algorithm, with support for arbitrary player counts.
- **PokerRL** / **Deep-CFR** (`EricSteinberger/PokerRL`, `EricSteinberger/Deep-CFR`) —
  a purpose-built, reasonably efficient framework implementing Deep CFR and Single Deep
  CFR specifically for NLHE-style games (as opposed to OpenSpiel's more general scope).
- **TexasSolver** / **postflop-solver** — free/open GTO postflop solvers (Discounted
  CFR-based); useful as an oracle/benchmark for postflop decisions, though heads-up/2-way
  pot focused, not directly a multiplayer training framework.
- **Unofficial "pluribus-poker-AI" reimplementations** on GitHub — community attempts to
  reproduce Pluribus's approach from the paper (not the real Pluribus, which was never
  released); useful as a reference for the algorithm shape, not as a drop-in dependency.
- **Slumbot / ACPC protocol** — a long-standing openly-playable strong heads-up bot and
  the Annual Computer Poker Competition's wire protocol, commonly used as a fixed
  reference opponent in heads-up papers (DecisionHoldem, PokerSkill above both benchmark
  against it). No equivalent openly-playable strong *multiplayer* reference bot appears
  to exist publicly.
- **GTO Wizard AI benchmark** — a live, evolving heads-up leaderboard; useful to watch,
  not usable as a dependency (proprietary agent, heads-up only, no multiplayer mode yet).

## 6. Gap analysis: pucker's engine vs. what any of the above needs

Before a Pluribus-style (or Deep-CFR-style) player can be trained *in pucker*, or a
network trained elsewhere can be *evaluated fairly against pucker's existing players*,
these engine gaps matter:

1. **Player count**: `State`'s hardcoded `player1..5_*` columns and `NUM_PLAYERS = 5`
   would need to become genuinely variable (or the comparison would need to be
   explicitly scoped to "5-max" and everything downstream, including any trained agent,
   built for exactly 5).
2. **Preflop betting round + real blind structure**: currently absent / non-standard.
   Any agent trained assuming standard NLHE rules (which every system in section 2 does)
   would not be evaluating "no-limit hold'em" as those systems define it unless this is
   fixed, or the comparison is explicitly scoped as "pucker's variant of hold'em."
3. **Bet sizing / action abstraction**: the existing players choose from effectively
   {fold, call, random-raise-multiplier, all-in}. A CFR-style or self-play-trained agent
   needs a well-defined, consistent action space (a fixed menu of bet sizes, e.g.
   fractions of pot) to reason about, and ideally the *same* action space the existing
   players are compared under, or the comparison is confounded by action-space
   mismatch.
4. **Throughput**: self-play / MCCFR training needs many orders of magnitude more hands
   than pucker's per-decision, synchronous, cross-process (Ruby ↔ HTTP ↔ Python)
   architecture can plausibly deliver. Any real training would likely happen in a
   separate, fast environment (Python/OpenSpiel/PokerRL, or a from-scratch fast
   simulator) with only the *trained policy* (not the training loop) wrapped as a pucker
   `Player` for the final match-play comparison — mirroring how `NnPlayer` already wraps
   an externally-trained model.
5. **Evaluation methodology**: given the section-3 point that multiplayer strategies
   can't be scored by exploitability, comparing against pucker's existing players will
   need to be **empirical head-to-head match play** over a large number of hands,
   ideally with an AIVAT-style variance-reduction estimator if statistical confidence at
   reasonable sample sizes matters (pucker doesn't currently know the other players'
   strategies precisely enough to compute AIVAT directly, since the BN/NN players are
   opaque function calls rather than exposed distributions — a solvable but real
   sub-problem).

## 7. Open questions to resolve during planning (not answered here)

- Scope: build/train the new agent for pucker's current simplified 5-seat rules as-is,
  or fix the engine (preflop betting, real blinds, arbitrary N) first and treat that as
  in-scope work?
- Algorithm family to target: reproduce something Pluribus-shaped (MCCFR self-play
  blueprint, possibly + depth-limited search) vs. a Deep-CFR-style neural approach vs.
  leaning on an existing framework (OpenSpiel/PokerRL) for training and only integrating
  the resulting policy into pucker.
- Where training happens: inside this repo/JRuby, or in a separate fast environment with
  only the final policy imported (this doc's read is that the latter is far more
  realistic given section 6.4).
- What "compare with existing players" means operationally: raw stack/mbb win rate over
  N hands, AIVAT-adjusted win rate, or something simpler given the opaque-strategy
  problem in 6.5.

## Key sources

- Brown & Sandholm, ["Superhuman AI for multiplayer poker"](https://www.science.org/doi/10.1126/science.aay2400), *Science* 2019 (Pluribus).
- Moravčík et al., "DeepStack: Expert-level artificial intelligence in heads-up no-limit poker", *Science* 2017.
- Brown & Sandholm, "Superhuman AI for heads-up no-limit poker: Libratus beats top professionals", *Science* 2018.
- Brown, Lerer, Gross, Sandholm, ["Deep Counterfactual Regret Minimization"](https://arxiv.org/abs/1811.00164), ICML 2019; Steinberger, ["Single Deep Counterfactual Regret Minimization"](https://arxiv.org/pdf/1901.07621).
- Brown, Bakhtin, Lerer, Gong, ["Combining Deep Reinforcement Learning and Search for Imperfect-Information Games" (ReBeL)](https://arxiv.org/abs/2007.13544), NeurIPS 2020.
- Schmid et al., ["Student of Games: A unified learning algorithm for both perfect and imperfect information games"](https://arxiv.org/abs/2112.03178), *Science Advances* 2023.
- Zhao et al., ["AlphaHoldem: High-Performance Artificial Intelligence for Heads-Up No-Limit Poker via End-to-End Reinforcement Learning"](https://cdn.aaai.org/ojs/20394/20394-13-24407-1-2-20220628.pdf), AAAI 2022.
- ["DecisionHoldem: Safe Depth-Limited Solving With Diverse Opponents for Imperfect-Information Games"](https://arxiv.org/pdf/2201.11580), 2022.
- Burch, Schmid, Burda, Bowling, ["AIVAT: A New Variance Reduction Technique for Agent Evaluation in Imperfect Information Games"](https://arxiv.org/abs/1612.06915), AAAI 2018.
- ["PokerGPT: An End-to-End Lightweight Solver for Multi-Player Texas Hold'em via Large Language Model"](https://arxiv.org/abs/2401.06781), 2024.
- ["PokerSkill: LLMs Can Play Expert-Level Poker without Training or Solvers"](https://arxiv.org/pdf/2605.30094), 2026; [GTO Wizard AI benchmark](https://benchmark.gtowizard.com/).
- [OpenSpiel](https://github.com/google-deepmind/open_spiel), [PokerRL](https://github.com/EricSteinberger/PokerRL), [Deep-CFR](https://github.com/EricSteinberger/Deep-CFR) (open-source frameworks).
- [`awesome-poker-ai`](https://github.com/PokerBotAI/awesome-poker-ai) — curated list, useful as a living index of the above.
