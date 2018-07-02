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
        expect(pot.all_bets).to be_instance_of Hash
      end
    end

    describe "#add_bet" do
      context "when player hasnt betted yet" do
        it "should increase the number of contributors" do
          populate_two_bets
          pot.add_bet(3, 100)
          expect(pot.all_bets.values.size).to be 3
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
          expect(sum.all_bets.size).to be 3
          expect(sum.all_bets[:one]).to be 20
          expect(sum.all_bets[:other]).to be 10
          expect(sum.all_bets[:another]).to be 10
        end
      end

      context "when called via +=" do
        it "should misc too pots in place" do
          @pot += @other_pot
          expect(@pot.all_bets.size).to be 3
          expect(@pot.all_bets[:one]).to be 20
          expect(@pot.all_bets[:other]).to be 10
          expect(@pot.all_bets[:another]).to be 10
        end
      end
    end

    describe "#total_contributed_by" do
      context "when player hasnt betted" do
        it "should return ZERO" do
          expect(pot.total_contributed_by('new player')).to be 0
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
