require "spec_helper"
require 'java'
java_import 'table.Card'

module Pucker
  describe Player do
    describe "#get_from_stack" do
      let(:p) { Player.new(100) }
      it "should get amount when player has more" do
        p.get_from_stack(20).should == 20
        p.stack.should == 80
      end

      it "should zero stack when player has less" do
        p.get_from_stack(120).should == 100
        p.stack.should == 0
      end
    end

    describe "#set_hand" do
      it "should put 2 cards on player's hand" do
        player = Player.new
        player.set_hand(Card.new(1), Card.new(2))
        player.hand.should have(2).items
      end
    end
  end
end
