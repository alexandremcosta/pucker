require 'spec_helper'
require 'java'
java_import 'table.Card'

module Pucker
  describe BestBnPlayer do
    let(:player) { BestBnPlayer.new }

    describe "#bet" do
      let (:state) { State.new(total_players: 5, position: 1, min_bet: 80) }

      context "when has low hand" do
        before do
          player.set_hand(Card.new(6), Card.new(7))
        end

        context "when scenario is bad" do
          let (:table_cards) { [Card.new(13), Card.new(27), Card.new(29)] }

          before do
            allow(state).to receive(:table_cards).and_return(table_cards)
          end

          it "should fold" do
            bet = player.bet(state)
            expect(bet).to be false
          end
        end

        context "when scenario is medium" do
          it "should fold" do
            allow(state).to receive(:min_bet).and_return(40)
            allow(state).to receive(:position).and_return(4)
            bet = player.bet(state)
            expect(bet).to be false
          end
        end

        context "when scenario is good" do
          it "should raise" do
            allow(state).to receive(:min_bet).and_return(0)
            allow(state).to receive(:position).and_return(4)
            bet = player.bet(state)
            expect(bet).to be > 0
          end
        end
      end

      context "when has avg hand" do
        before do
          player.set_hand(Card.new(6), Card.new(7))
          table_cards = [Card.new(16), Card.new(18), Card.new(19)]
          allow(state).to receive(:table_cards).and_return(table_cards)
        end

        context "when scenario is bad" do
          it "should fold" do
            bet = player.bet(state)
            expect(bet).to be false
          end
        end
        context "when scenario is medium" do
          it "should fold" do
            allow(state).to receive(:min_bet).and_return(40)
            allow(state).to receive(:position).and_return(4)
            bet = player.bet(state)
            expect(bet).to be false
          end
        end
        context "when scenario is good" do
          it "should raise" do
            allow(state).to receive(:min_bet).and_return(0)
            allow(state).to receive(:position).and_return(4)
            bet = player.bet(state)
            expect(bet).to be > 0
          end
        end
      end

      context "when has high hand" do
        before do
          player.set_hand(Card.new(6), Card.new(7))
          table_cards = [Card.new(16), Card.new(32), Card.new(19)]
          allow(state).to receive(:table_cards).and_return(table_cards)
        end
        context "when scenario is bad" do
          it "should check" do
            bet = player.bet(state)
            expect(bet).to be 80
          end
        end
        context "when scenario is medium" do
          it "should raise" do
            allow(state).to receive(:position).and_return(4)
            allow(state).to receive(:min_bet).and_return(40)
            bet = player.bet(state)
            expect(bet).to be > 40
          end
        end
        context "when scenario is good" do
          it "should raise" do
            allow(state).to receive(:position).and_return(4)
            allow(state).to receive(:min_bet).and_return(0)
            bet = player.bet(state)
            expect(bet).to be > 0
          end
        end
      end
    end
  end

  describe BnPlayer do
    let(:player) { BnPlayer.new }

    describe "#bet" do

      context "when has low hand" do
        before { player.set_hand(Card.new(6), Card.new(7)) }

        context "when scenario is bad" do
          it "should fold" do
            state = State.new(min_bet: 80, table_cards: [])
            bet = player.bet(state)
            expect(bet).to be false
          end
        end
        context "when scenario is medium" do
          it "should fold" do
            state = State.new(min_bet: 40, table_cards: [])
            bet = player.bet(state)
            expect(bet).to be false
          end
        end
        context "when scenario is good" do
          #if position is good and min_bet = 0 => scenario IS good
          it "should raise" do
            state = State.new(min_bet: 0, total_players: 5, position: 5, table_cards: [])
            bet = player.bet(state)
            expect(bet).to be > 0
          end
        end
      end

      context "when has avg hand" do
        before do
          player.set_hand(Card.new(6), Card.new(7))
        end

        let(:state) { State.new(min_bet: 80, table_cards: [Card.new(16), Card.new(18), Card.new(19)]) }

        context "when scenario is bad" do
          it "should fold" do
            bet = player.bet(state)
            expect(bet).to be false
          end
        end
        context "when scenario is medium" do
          it "should fold" do
            allow(state).to receive(:min_bet).and_return(40)
            bet = player.bet(state)
            expect(bet).to be false
          end
        end
        context "when scenario is good" do
          #if position is good and min_bet = 0 => scenario IS good
          it "should raise" do
            allow(state).to receive(:min_bet).and_return(0)
            allow(state).to receive(:position).and_return(5)
            allow(state).to receive(:total_players).and_return(5)
            bet = player.bet(state)
            expect(bet).to be > 0
          end
        end
      end

      context "when has high hand" do
        before do
          player.set_hand(Card.new(6), Card.new(7))
        end

        let(:state) { State.new(min_bet: 80, table_cards: [Card.new(16), Card.new(32), Card.new(19)]) }
        context "when scenario is bad" do
          it "should check" do
            bet = player.bet(state)
            expect(bet).to be 80
          end
        end
        context "when scenario is medium" do
          it "should raise" do
            allow(state).to receive(:min_bet).and_return(40)
            bet = player.bet(state)
            expect(bet).to be > 40
          end
        end
        context "when scenario is good" do
          it "should raise" do
            allow(state).to receive(:min_bet).and_return(0)
            bet = player.bet(state)
            expect(bet).to be > 0
          end
        end
      end
    end
  end

  describe SimpleBnPlayer do
    let(:player) { SimpleBnPlayer.new }
    describe "#bet" do
      context "when has low hand" do
        before { player.set_hand(Card.new(6), Card.new(7)) }
        context "when min_bet equals zero" do
          it "should check" do
            state = State.new(min_bet: 0, table_cards: [], total_players: 2)
            bet = player.bet(state)
            expect(bet).to be 0
          end
        end
        context "when min_bet greater than zero" do
          it "should fold" do
            state = State.new(min_bet: 30, table_cards: [], total_players: 2)
            bet = player.bet(state)
            expect(bet).to be false
          end
        end
      end

      context "when has avg hand" do
        before { player.set_hand(Card.new(0), Card.new(13)) } # pair of two
        context "when min_bet equals zero" do
          it "should raise" do
            state = State.new(min_bet: 0, table_cards: [], total_players: 2)
            bet = player.bet(state)
            expect(bet).to be > 0
          end
        end
        context "when min_bet greater than zero" do
          it "should check" do
            state = State.new(min_bet: 30, table_cards: [], total_players: 2)
            bet = player.bet(state)
            expect(bet).to be 30
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
            state = State.new(min_bet: 0, table_cards: @table_cards, total_players: 2)
            bet = player.bet(state)
            expect(bet).to be > 0
          end
        end
        context "when min_bet greater than zero" do
          it "should raise" do
            state = State.new(min_bet: 30, table_cards: @table_cards, total_players: 2)
            bet = player.bet(state)
            expect(bet).to be > 30
          end
        end
      end
    end
  end
end

