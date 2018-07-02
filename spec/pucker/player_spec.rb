require "spec_helper"
require 'java'
java_import 'table.Card'

module Pucker
  describe Player do
    describe "#initialize" do
      it "should have a uniq id" do
        ids = 100.times.map { Player.new.id }
        expect(ids.uniq.size).to be 100
        expect(ids.uniq).to eq(ids)
      end
    end

    describe "#bet_if_active" do
      let(:player) { Player.new }
      subject { player.bet_if_active(min_bet: 20) }

      it "should return what #bet returns" do
        expect(player).to receive(:bet).with(min_bet: 20).and_return('any number')
        expect(subject).to eq('any number')
      end

      context "when player is NOT active" do
        before { allow(player).to receive(:active?).and_return(false) }
        it { is_expected.to be_falsey }
      end
    end

    describe "#bet" do
      it "should check every time" do
        expect(Player.new.bet(min_bet: 30)).to be 30
      end
    end

    describe "#get_from_stack" do
      let(:p) { Player.new(100) }

      context "when player has more" do
        it "should get amount" do
          expect(p.get_from_stack(20)).to be 20
          expect(p.stack).to be 80
        end
      end

      context "when player has less" do
        it "should zero stack" do
          expect(p.get_from_stack(120)).to be 100
          expect(p.stack).to be 0
        end

        it "should desactivate player" do
          p.get_from_stack(120)
          expect(p).not_to be_active
        end
      end
    end

    describe "#set_hand" do
      it "should put 2 cards on player's hand" do
        player = Player.new
        player.set_hand(Card.new(1), Card.new(2))
        expect(player.hand.size).to be 2
      end
    end

    describe "#hand_rank" do
      before do
        @player = Player.new
        @player.set_hand(Card.new(6), Card.new(7))
        @table = []
        1.upto(4) do |index| @table << Card.new(index) end
      end

      it "should rank players hand according to table cards" do
        first_rank = @player.hand_rank(@table)
        @table << Card.new(5)
        second_rank = @player.hand_rank(@table)
        expect(second_rank).to be > first_rank
      end

      it "shouldnt call HandEvaluator again if table cards hasnt changed" do
        expect(HandEvaluator).to receive(:rank_hand).once
        2.times do @player.hand_rank(@table) end
      end
    end

    context "protected methods" do
      describe "#full_hand" do
        it "should misc players and table cards" do
          table_cards = []
          1.upto(5) do |index| table_cards << Card.new(index) end

          player = Player.new
          player.set_hand(Card.new(6), Card.new(7))

          expect(player.send(:full_hand, table_cards).size).to be 7
        end
      end
    end
  end

  describe DummyPlayer do
    let(:min_value) { 10 }
    let(:p) { DummyPlayer.new(100) }
    subject { p.bet(min_bet: min_value) }

    describe "#bet" do
      context "when he folds" do
        before { expect(p).to receive(:rand).and_return(0.1) }
        it { is_expected.to be false }
      end
      context "when he checks" do
        before { expect(p).to receive(:rand).and_return(0.7) }
        it { is_expected.to be min_value }
      end
      context "when he raises" do
        before { allow(p).to receive(:rand).and_return(0.9) }
        it "should return a value between min_value and stack" do
          is_expected.to be_between(min_value, p.stack)
        end
      end
    end
  end
end
