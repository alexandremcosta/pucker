require "spec_helper"
require 'java'
java_import 'table.Card'

module Pucker
  describe Player do
    describe "#set_hand" do
      it "should put 2 cards on player's hand" do
        player = Player.new
        player.set_hand(Card.new(1), Card.new(2))
        player.hand.should have(2).items
      end
    end
  end
end
