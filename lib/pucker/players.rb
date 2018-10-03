# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Implements trivial players. Player class always checks. DummyPlayer class bets randomly.

require_relative 'sequence'
require 'java'
java_import 'table.Hand'
java_import 'table.HandEvaluator'

module Pucker
  class Player
    attr_accessor :stack
    attr_reader :id

    def initialize(amount=STACK)
      @active = true
      @allin = false
      @stack = amount
      @id = self.class.name.split('::').last + Sequence.next.to_s
    end

    def get_from_stack(amount)
      if @stack <= amount
        inactive!
        allin!
        tmp = @stack
        @stack = 0
        return tmp
      else
        @stack -= amount
        return amount
      end
    end

    def bet_if_active(opts={})
      bet(opts) if active?
    end

    def bet(opts={})
      min_bet = opts[:min_bet]
      get_from_stack(min_bet)
    end

    def active?
      @active
    end

    def allin?
      @allin
    end

    def hand
      @hand ||= Hand.new
    end

    def set_hand(card1, card2)
      reset_hand
      hand.add_card(card1)
      hand.add_card(card2)
    end

    def hand_rank(table_cards)
      old_table_cards = @table_cards
      @table_cards = Array.new(table_cards)
      if old_table_cards != @table_cards
        @rank = HandEvaluator.rank_hand(full_hand(@table_cards))
      end
      @rank
    end

    def reward(price)
      @stack += price
    end

    def reset_round_state
      @active = true
      @allin = false
    end

    def fold
      inactive!
    end

    def to_s
      "#{id}\t- #{hand} - #{stack}"
    end

    protected
    def full_hand(table_cards)
      full_hand = Hand.new(hand)
      table_cards.each do |card| full_hand.add_card(card) end
      return full_hand
    end
    def reset_hand
      @hand = hand.make_empty
    end
    def inactive!
      @active = false
    end
    def allin!
      @allin = true
    end
    def raise_from(min_bet)
      min_bet = BIG_BLIND if min_bet == 0

      if stack > (4 * min_bet)
        get_from_stack(2 * min_bet)
      else # ALLIN
        get_from_stack(stack)
      end
    end
  end

  class DummyPlayer < Player
    def bet(opts={})
      min_bet = opts[:min_bet]

      choice = rand

      if min_bet > 0 && choice < 0.2 # FOLD
        fold
      elsif choice < 0.85 # CHECK
        get_from_stack(min_bet)
      else # RAISE
        raise_from(min_bet)
      end
    end
  end
end
