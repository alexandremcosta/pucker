require "spec_helper"

module Pucker
  describe Pot do
    let(:pot) { Pot.new(3) }

    def populate_two_bets
      pot.add_bet(0, :preflop, 50)
      pot.add_bet(1, :preflop, 100)
    end

    describe "#all_bets" do
      it "should return a hash" do
        expect(pot.all_bets).to be_instance_of Array
      end
    end

    describe "#add_bet" do
      it "should increase the number of contributions" do
        populate_two_bets
        pot.add_bet(1, :preflop, 200)
        expect(pot.all_bets[1][:preflop].size).to be > pot.all_bets[0][:preflop].size
        expect(pot.all_bets[1][:preflop].size).to be > pot.all_bets[2][:preflop].size

        pot.add_bet(2, :preflop, 200)
        expect(pot.all_bets[2][:preflop].size).to be 1
      end
    end

    describe "#merge!" do
      before do
        @pot = Pot.new(3)
        @other_pot = Pot.new(3)
        @pot.add_bet(0, :preflop, 10)
        @pot.add_bet(1, :preflop, 10)
        @other_pot.add_bet(0, :flop, 20)
        @other_pot.add_bet(2, :flop, 20)
      end

      context "when directed called" do
        it "should merge too pots" do
          @pot.merge!(@other_pot)
          expect(@pot.all_bets[0][:preflop]).to eq([10])
          expect(@pot.all_bets[0][:flop]).to eq([20])
          expect(@pot.all_bets[1][:preflop]).to eq([10])
          expect(@pot.all_bets[1][:flop]).to eq([])
          expect(@pot.all_bets[2][:preflop]).to eq([])
          expect(@pot.all_bets[2][:flop]).to eq([20])
        end
      end
    end

    describe "#total_contributed_by" do
      context "when player hasnt betted" do
        it "should return ZERO" do
          expect(pot.total_contributed_by(0)).to be 0
          expect(pot.total_contributed_by(1)).to be 0
          expect(pot.total_contributed_by(2)).to be 0
        end
      end

      context "when player has betted" do
        it "should return total betted" do
          pot.add_bet(0, :preflop, 50)
          pot.add_bet(0, :preflop, 20)
          expect(pot.total_contributed_by(0)).to be 70
        end
      end
    end

    describe "#empty" do
      it "should be empty when initialized" do
        expect(pot.empty?).to be true
      end
      it "should be empty when there arent bets" do
        populate_two_bets
        expect(pot.empty?).to be false
        pot.get_from_all(100)
        expect(pot.empty?).to be true
      end
    end

    describe "#get_from_all" do
      it "should get an amount from every players bet" do
        populate_two_bets
        expect(pot.get_from_all(50)).to be 100
        expect(pot.get_from_all(50)).to be 50
        expect(pot.get_from_all(50)).to be 0
      end
    end
  end
end
