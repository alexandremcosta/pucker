require 'spec_helper'
require 'java'
java_import 'table.Card'

module Pucker
  describe SimpleBnPlayer do
    let(:player) { SimpleBnPlayer.new }
    describe "#bet" do
      context "when has low hand" do
        before { player.set_hand(Card.new(6), Card.new(7)) }
        context "when min_bet equals zero" do
          it "should check" do
            player.bet(min_bet: 0, table_cards: [], num_players: 2).should == 0
          end
        end
        context "when min_bet greater than zero" do
          it "should fold" do
            player.bet(min_bet: 30, table_cards: [], num_players: 2).should be_false
          end
        end
      end

      context "when has avg hand" do
        before { player.set_hand(Card.new(0), Card.new(13)) } # pair of two
        context "when min_bet equals zero" do
          it "should raise" do
            player.bet(min_bet: 0, table_cards: [], num_players: 2).should > 0
          end
        end
        context "when min_bet greater than zero" do
          it "should check" do
            player.bet(min_bet: 30, table_cards: [], num_players: 2).should == 30
          end
        end
      end

      context "when has high hand" do
        before do
          player.set_hand(Card.new(0), Card.new(13)) # pair of two
          @table_cards = [Card.new(26)] # another two
        end
        context "when min_bet equals zero" do
          it "should raise" do
            player.bet(min_bet: 0, table_cards: @table_cards, num_players: 2).should > 0
          end
        end
        context "when min_bet greater than zero" do
          it "should raise" do
            player.bet(min_bet: 30, table_cards: @table_cards, num_players: 2).should > 30
          end
        end
      end
    end
  end
end
