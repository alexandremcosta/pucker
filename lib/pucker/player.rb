require 'java'
java_import 'table.Hand'

module Pucker
  class Player
    attr_accessor :stack

    def initialize(amount=400)
      @active = true
      @stack = amount
    end

    def get_from_stack(amount)
      if @stack < amount
        tmp = @stack
        @active = false
        @stack = 0
        return tmp
      else
        @stack -= amount
        return amount
      end
    end

    def bet
      10
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

    private
    def reset_hand
      @hand = hand.make_empty
    end
  end
end
