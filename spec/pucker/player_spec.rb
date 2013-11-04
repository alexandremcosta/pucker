require "spec_helper"
require 'java'
java_import 'table.Card'

module Pucker
  describe Player do
    describe "#bet" do
      it "should check every time" do
        Player.new.bet(30).should == 30
      end
    end

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
        second_rank.should > first_rank
      end

      it "shouldnt call HandEvaluator again if table cards hasnt changed" do
        HandEvaluator.should_receive(:rank_hand).once
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

          player.send(:full_hand, table_cards).should have(7).items
        end
      end
    end
  end

  describe DummyPlayer do
    let(:min_value) { 0 }
    let(:p) { DummyPlayer.new(100) }
    subject { p.bet(min_value) }

    describe "#bet" do
      context "when he folds" do
        before { p.should_receive(:rand).and_return(0.2) }
        it { should be_false }
      end
      context "when he checks" do
        before { p.should_receive(:rand).and_return(0.7) }
        it { should == min_value }
      end
      context "when he raises" do
        before { p.stub(:rand).and_return(0.9, 50) }
        it "should return a value between min_value and stack" do
          subject.should be_between(min_value, p.stack)
        end
      end
    end
  end
end
