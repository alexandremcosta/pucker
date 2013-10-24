require 'java'
java_import 'table.Hand'

module Pucker
  class DummyPlayer < Player
    def bet(min_bet = 0)
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

    protected
    def fold
      @active = false
    end
  end

  class Player
    attr_accessor :stack

    def initialize(amount=STACK)
      @active = true
      @stack = amount
    end

    def get_from_stack(amount)
      if @stack <= amount
        tmp = @stack
        @active = false
        @stack = 0
        return tmp
      else
        @stack -= amount
        return amount
      end
    end

    def bet(min_bet = 0)
      get_from_stack(40)
    end

    def active?
      @active
    end

    def hand
      @hand ||= Hand.new
    end

    def set_hand(card1, card2)
      reset_hand
      hand.add_card(card1)
      hand.add_card(card2)
    end

    def full_hand(table_cards)
      full_hand = Hand.new(hand)
      table_cards.each do |card| full_hand.add_card(card) end
      return full_hand
    end

    def reward(price)
      @stack += price
    end

    private
    def reset_hand
      @hand = hand.make_empty
    end
  end
end
