require "spec_helper"

#TODO: separar como integration tests
module Pucker
  describe Game do
    describe "#initialize" do
      it "should have 5 players by default" do
        game = Game.new
        game.players.should have(5).items
      end

      it "should allow definition of number of players" do
        game = Game.new(2)
        game.players.should have(2).items
      end
    end

    describe "private methods" do
      describe "#prepare_players" do
        before do
          @game  = Game.new
        end
        it "should delete players with insuficient stack" do
          first_player = @game.players.first
          last_player = @game.players.last
          first_player.stack = 0
          last_player.stack = 1
          @game.send(:prepare_players)
          @game.players.should_not include(first_player)
          @game.players.should include(last_player)
        end
        it "should set all players active and remove allin states" do
          first_player = @game.players.first
          last_player = @game.players.last
          first_player.send(:inactive!)
          last_player.send(:allin!)

          @game.send(:prepare_players)
          first_player.active?.should be_true
          last_player.allin?.should be_false
        end
        it "should rotate players" do
          second_player = @game.players[1]
          @game.send(:prepare_players)
          @game.players.first.should == second_player
        end
      end
    end
  end
end
