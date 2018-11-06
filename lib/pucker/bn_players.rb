require 'ruby-debug'
# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Implementation of players that use Bayesian Networks to play poker.

require 'sbn'
require_relative 'players'
require_relative 'bayesian_networks'

module Pucker
  class SimpleBnPlayer < Player
    def initialize(amount=STACK)
      super(amount)
      build_bayesian_network
    end

    def bet(state)
      evidence = build_evidence(state)
      chance   = chance_to_win(evidence)

      if chance > 0.75 && state.min_bet < (8 * BIG_BLIND)
        raise_from(state.min_bet)
      elsif chance > 0.5 || state.min_bet == 0
        get_from_stack(state.min_bet)
      else
        fold
      end
    end

    protected
    def build_evidence(state)
      hr = discrete_hand_rank(state.table_cards)
      mb = discrete_min_bet(state.min_bet)

      {min_bet: mb, hand_rank: hr}
    end

    def discrete_min_bet(min_bet)
      min_bet > 0 ? :over_zero : :zero
    end

    def chance_to_win(evidence)
      @net.set_evidence(evidence)
      @net.query_variable(:result)[:true]
    end

    def table_rank(table_cards)
      if table_cards.any?
        table = Hand.new
        table_cards.each do |card| table.add_card(card) end
        return HandEvaluator.rank_hand(table)
      end
      return 0
    end

    def discrete_hand_rank(table_cards)
      tr = table_rank(table_cards)
      hr = hand_rank(table_cards)

      if hr - tr > 10000
        if hr >= 742755 # two pairs of two and three 1113879 # triple of two
          return :high
        elsif hr >= 371293 # pair of two
          return :avg
        end
      end

      return :low
    end

    def build_bayesian_network
      @net = SimpleBn.get
    end
  end

  class BnPlayer < SimpleBnPlayer
    def bet(state)
      evidence = build_evidence(state)
      chance   = chance_to_win(evidence)

      if chance > 0.7 && state.min_bet < (12 * BIG_BLIND)
        raise_from(state.min_bet * 2)
      elsif chance > 0.40 || state.min_bet == 0
        get_from_stack(state.min_bet)
      else
        fold
      end
    end

    protected
    def discrete_hand_rank(table_cards)
      tr = table_rank(table_cards)
      hr = hand_rank(table_cards)

      if hr - tr > 10000
        if hr >= 742755 # two pairs of two and three # 1113879 # triple of two
          return :high
        elsif hr >= 386672 # pair of nines
          return :avg
        end
      end

      return :low
    end

    def discrete_table_rank(table_cards)
      tr = table_rank(table_cards)
      if tr >= 371293 # pair of two
        return :high
      else
        return :low
      end
    end

    def discrete_min_bet(min_bet)
      if min_bet == 0
        :zero
      elsif min_bet >= 3*BIG_BLIND
        :high
      else
        :low
      end
    end

    def build_evidence(state)
      hr = discrete_hand_rank(state.table_cards)
      tr = discrete_table_rank(state.table_cards)
      mb = discrete_min_bet(state.min_bet)
      position = discrete_position(state.total_players, state.position)

      mb = :low if mb == :zero && position == :bad

      {min_bet: mb, hand_rank: hr, table_rank: tr}
    end

    def discrete_position(total, index)
      return :bad if (index == 0 || index == 1 || index == 2) && total >= 4
      return :good
    end

    def build_bayesian_network
      @net = GoodBn.get
    end
  end

  class BestBnPlayer < BnPlayer
    def bet(state)
      evidence = build_evidence(state)
      chance   = chance_to_win(evidence)

      if chance > 0.9 || (chance > 0.75 && hand_rank(state.table_cards) >= 1113879)
        raise_from(state.min_bet * 4)
      elsif chance > 0.7 && state.min_bet < (12 * BIG_BLIND)
        raise_from(state.min_bet * 2)
      elsif chance > 0.45 || state.min_bet == 0
        get_from_stack(state.min_bet)
      else
        fold
      end
    end

    def chance_to_win(evidence)
      a = super
      # LOG.debug('Chance: ' + a.to_s)
      return a
    end

    protected
    def build_evidence(state)
      hr = discrete_hand_rank(state.table_cards)
      mb = discrete_min_bet(state.min_bet)
      position = discrete_position(state.total_players, state.position)

      evidence = {min_bet: mb, hand_rank: hr, position: position}
      # LOG.debug(evidence.to_s)
      return evidence
    end

    def discrete_position(total, index)
      return :high if index == total - 1
      return :high if total > 3 && index >= total - 2
      return :low
    end

    def build_bayesian_network
      @net = BestBn.get
    end
  end
end
