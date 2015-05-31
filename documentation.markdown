Run options: include {:wip=>true}

All examples were filtered out; ignoring {:wip=>true}

### Pucker::BestBnPlayer
  - \#bet
    - when has low hand
      - when scenario is bad
        - should fold
      - when scenario is medium
        - should fold
      - when scenario is good
        - should raise
    - when has avg hand
      - when scenario is bad
        - should fold
      - when scenario is medium
        - should fold
      - when scenario is good
        - should raise
    - when has high hand
      - when scenario is bad
        - should check
      - when scenario is medium
        - should raise
      - when scenario is good
        - should raise

### Pucker::BnPlayer
  - \#bet
    - when has low hand
      - when scenario is bad
        - should fold
      - when scenario is medium
        - should fold
      - when scenario is good
        - should raise
    - when has avg hand
      - when scenario is bad
        - should fold
      - when scenario is medium
        - should fold
      - when scenario is good
        - should raise
    - when has high hand
      - when scenario is bad
        - should check
      - when scenario is medium
        - should raise
      - when scenario is good
        - should raise

### Pucker::SimpleBnPlayer
  - \#bet
    - when has low hand
      - when min\_bet equals zero
        - should check
      - when min\_bet greater than zero
        - should fold
    - when has avg hand
      - when min\_bet equals zero
        - should raise
      - when min\_bet greater than zero
        - should check
    - when has high hand
      - when min\_bet equals zero
        - should raise
      - when min\_bet greater than zero
        - should raise

### Pucker::Player
  - \#initialize
    - should have a uniq id
  - \#bet\_if\_active
    - should return what \#bet returns
    - when player is NOT active
      - should be false
  - \#bet
    - should check every time
  - \#get\_from\_stack
    - when player has more
      - should get amount
    - when player has less
      - should zero stack
      - should desactivate player
  - \#set\_hand
    - should put 2 cards on player's hand
  - \#hand\_rank
    - should rank players hand according to table cards
    - shouldnt call HandEvaluator again if table cards hasnt changed
  - protected methods
    - \#full\_hand
      - should misc players and table cards

### Pucker::DummyPlayer
  - \#bet
    - when he folds
      - should be false
    - when he checks
      - should == 10
    - when he raises
      - should return a value between min\_value and stack

### Pucker::Pot
  - \#all\_bets
    - should return a hash
  - \#add\_bet
    - when player hasnt betted yet
      - should increase the number of contributors
  - \#sum
    - when directed called
      - should misc too pots
    - when called via +=
      - should misc too pots in place
  - \#total\_contributed\_by
    - when player hasnt betted
      - should return ZERO
  - \#empty
    - should be empty when initialized
    - should be empty when there arent bets
  - \#get\_from\_all
    - should get an amount from every players bet

### Pucker::PlayerGroup
  - \#[]
    - should delegate to container
  - \#set\_hands
    - should give 2 cards to each player
  - \#reset
    - shouldnt change players size
    - when players have ZERO stack
      - should increase back its stack

### Pucker::Game
  - \#initialize
    - should have 5 players by default
    - should allow definition of number of players
  - \#collect\_bets
    - collect bets (PENDING: Not yet implemented)
  - private methods
    - \#prepare\_players
      - should rebuy players with insuficient stack
      - should set all players active and remove allin states
      - should rotate players
    - integration tests for rewards
      - \#eligible\_players\_by\_rank
        - sort players
      - reward eligible\_players\_by\_rank
        - rewards players

### Pucker::Dealer
  - \#deal
    - deals cards
    - deals 52 different cards
    - doesn't deal 53 cards
  - \#reset
    - allows dealer to continue dealing
    - should deal cards in different order

Pending:
  Pucker::Game#collect_bets collect bets
    # Not yet implemented
    # ./spec/pucker/game_spec.rb:19

Finished in 10.19 seconds
63 examples, 0 failures, 1 pending
Coverage report generated for RSpec to /home/alexandre/Dev/pucker/coverage. 619 / 682 LOC (90.76%) covered.
