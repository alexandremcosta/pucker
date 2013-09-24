require "spec_helper"
require 'java'
java_import 'table.Card'

module Pucker
  describe Player do
    describe "#get_from_stack" do
      let(:p) { Player.new(100) }

      context "when player has more" do
        it "should get amount" do
          p.get_from_stack(20).should == 20
          p.stack.should == 80
        end
      end

      context "when player has less" do
        it "should zero stack" do
          p.get_from_stack(120).should == 100
          p.stack.should == 0
        end

        it "should desactivate player" do
          p.get_from_stack(120)
          p.active?.should == false
        end
      end
    end

    describe "#set_hand" do
      it "should put 2 cards on player's hand" do
        player = Player.new
        player.set_hand(Card.new(1), Card.new(2))
        player.hand.should have(2).items
      end
    end

    describe "#full_hand" do
      it "should misc players and table cards" do
        table_cards = []
        1.upto(5) do |index| table_cards << Card.new(index) end

        player = Player.new
        player.set_hand(Card.new(6), Card.new(7))

        player.full_hand(table_cards).should have(7).items
      end
    end
  end
end
