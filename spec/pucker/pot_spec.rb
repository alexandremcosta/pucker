require "spec_helper"

module Pucker
  describe Pot do
    let(:pot) { Pot.new }

    describe "#all_bets" do
      it "should return a hash" do
        pot.all_bets.should be_an_instance_of Hash
      end
    end
    
    describe "#add_bet" do
      context "when player hasnt betted yet" do
        it "should increase the number of contributors" do
          amount = 50
          player = double(:player)
          pot.contributors.should be_empty
          pot.add_bet(player, amount)
          pot.contributors.should have(1).player
        end
      end
    end

    describe "#get_from_all" do
      it "should get an amount from every players bet"
    end
  end
end
