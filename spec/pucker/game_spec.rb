require "spec_helper"

#TODO: separar como integration tests
module Pucker
  describe Game do
    describe "#initialize" do
      it "should have 5 players by default" do
        game = Game.new
        expect(game.players.size).to be 5
      end

      it "should allow definition of number of players" do
        game = Game.new(2)
        expect(game.players.size).to be 2
      end
    end

    describe "#collect_bets" do
      it "collect bets"
    end

    describe "private methods" do
      describe "#prepare_players" do
        before do
          @game  = Game.new
        end
        it "should rebuy players with insuficient stack" do
          player = @game.players.first
          player.stack = 0
          @game.send(:prepare_players)
          expect(player.stack).to be > 0
        end
        it "should set all players active and remove allin states" do
          first_player = @game.players.first
          last_player = @game.players.last
          first_player.send(:inactive!)
          last_player.send(:allin!)

          @game.send(:prepare_players)
          expect(first_player).to be_active
          expect(last_player).not_to be_allin
        end
        it "should rotate players" do
          second_player = @game.players[1]
          @game.send(:prepare_players)
          expect(@game.players.first).to be second_player
        end
      end

      context "integration tests for rewards" do
        # Scenario described in:
        # http://stackoverflow.com/questions/5462583/poker-side-pot-algorithm

        let(:game) { Game.new(3, 1000) }

        before do
          allow(game.players[0]).to receive(:hand_rank).and_return(10)
          allow(game.players[1]).to receive(:hand_rank).and_return(2)
          allow(game.players[2]).to receive(:hand_rank).and_return(10)
          pot = Pot.new
          pot.add_bet(game.players[0], game.players[0].get_from_stack(100))
          pot.add_bet(game.players[1], game.players[1].get_from_stack(80))
          pot.add_bet(game.players[2], game.players[2].get_from_stack(20))
          allow(game).to receive(:pot).and_return(pot)
        end

        describe "#eligible_players_by_rank" do
          it "sort players" do
            tied_player1 = game.send(:eligible_players_by_rank).first.first
            tied_player2 = game.send(:eligible_players_by_rank).last.first
            expect(tied_player1).to be game.players[2]
            expect(tied_player2).to be game.players[1]
          end
        end

        describe "reward eligible_players_by_rank" do
          it "rewards players" do
            eligible = game.send(:eligible_players_by_rank)
            game.send(:reward, eligible)
            expect(game.players[0].stack).to be 1070
            expect(game.players[1].stack).to be 920
            expect(game.players[2].stack).to be 1010
          end
        end
      end
    end
  end
end
