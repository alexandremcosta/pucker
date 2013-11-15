require "spec_helper"
require 'pry'

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

    describe "#sum" do
      before do
        @pot = Pot.new
        @other_pot = Pot.new
        @pot.add_bet(:one, 10)
        @pot.add_bet(:other, 10)
        @other_pot.add_bet(:one, 10)
        @other_pot.add_bet(:another, 10)
      end

      context "when directed called" do
        it "should misc too pots" do
          sum = @pot.sum(@other_pot)
          sum.all_bets.count.should == 3
          sum.all_bets[:one].should == 20
          sum.all_bets[:other].should == 10
          sum.all_bets[:another].should == 10
        end
      end

      context "when called via +=" do
        it "should misc too pots in place" do
          @pot += @other_pot
          @pot.all_bets.count.should == 3
          @pot.all_bets[:one].should == 20
          @pot.all_bets[:other].should == 10
          @pot.all_bets[:another].should == 10
        end
      end
    end

    describe "#total_contributed_by" do
      context "when player hasnt betted" do
        it "should return ZERO" do
          pot.total_contributed_by('new player').should == 0
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
