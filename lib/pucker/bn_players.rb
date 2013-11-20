require 'sbn'
require_relative 'players'

module Pucker
  class SimpleBnPlayer < Player
    def initialize(amount=STACK)
      super(amount)
      build_bayesian_network
    end

    def bet(opts={})
      evidence = build_evidence(opts)
      chance = chance_to_win(evidence)

      if chance > 0.75 && opts[:min_bet] < (8 * BIG_BLIND)
        raise_from(opts[:min_bet])
      elsif chance > 0.5
        get_from_stack(opts[:min_bet])
      else
        fold
      end
    end

    private
    def build_evidence(opts)
      hr = discrete_hand_rank(opts[:table_cards])
      mb = discrete_min_bet(opts[:min_bet])

      {min_bet: mb, hand_rank: hr}
    end

    def discrete_min_bet(min_bet)
      min_bet > 0 ? :over_zero : :zero
    end

    protected
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
        if hr >= 1113879 # triple of two
          return :high
        elsif hr >= 371293 # pair of two
          return :avg
        end
      end

      return :low
    end

    def build_bayesian_network
      @net = Sbn::Net.new("Pucker")
      min_bet = Sbn::Variable.new(@net, :min_bet, [0.5, 0.5], [:zero, :over_zero])
      hand_rank = Sbn::Variable.new(@net, :hand_rank, [0.3, 0.6, 0.1], [:low, :avg, :high])
      result = Sbn::Variable.new(@net, :result, [0.6,0.4,0.8,0.2,0.9,0.1,0.1,0.9,0.6,0.4,0.9,0.1])
      min_bet.add_child(result)
      hand_rank.add_child(result)
    end
  end
end
