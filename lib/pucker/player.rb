require 'java'
java_import 'table.Hand'

module Pucker
  class Player
    def bet
      10
    end

    def active?
      true
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
