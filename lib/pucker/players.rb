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
        tmp = @stack
        inactive!
        allin!
        @stack = 0
        return tmp
      else
        @stack -= amount
        return amount
      end
    end

    def bet_if_active(min_bet)
      bet(min_bet) if active?
    end

    def bet(min_bet)
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
  end

  class DummyPlayer < Player
    def bet(min_bet)
      choice = rand

      if (choice < 0.3) || (@stack - min_bet) < (@stack / 2) #FOLD
        fold
      elsif choice < 0.8 #CHECK
        get_from_stack(min_bet)
      else #RAISE
        amount = min_bet
        amount += rand(@stack-amount+1)
        get_from_stack(amount)
      end
    end
  end
end
