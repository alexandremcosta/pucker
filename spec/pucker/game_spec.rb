require "spec_helper"

#TODO: separar como integration tests
module Pucker
  describe Game do
    describe "#initialize" do
      it "should create 5 players by default" do
        game = Game.new
        game.players.should have(5).items
      end
    end
  end
end
