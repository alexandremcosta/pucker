require "spec_helper"

module Pucker
  describe Pot do
    let(:pot) { Pot.new }

    def populate_two_bets
      pot.all_bets[1] = 50
      pot.all_bets[2] = 100
    end

    describe "#all_bets" do
      it "should return a hash" do
        pot.all_bets.should be_an_instance_of Hash
      end
    end
    
    describe "#add_bet" do
      context "when player hasnt betted yet" do
        it "should increase the number of contributors" do
          populate_two_bets
          pot.add_bet(3, 100)
          pot.all_bets.values.should have(3).bets
        end
      end
    end

    describe "#empty" do
      it "should be empty when initialized" do
        pot.empty?.should be_true
      end
      it "should be empty when there arent bets" do
        populate_two_bets
        pot.empty?.should be_false
        pot.get_from_all(100)
        pot.empty?.should be_true
      end
    end

    describe "#get_from_all" do
      it "should get an amount from every players bet" do
        populate_two_bets
        pot.get_from_all(50).should == 100
        pot.get_from_all(50).should == 50
        pot.get_from_all(50).should == 0
      end
    end
  end
end
