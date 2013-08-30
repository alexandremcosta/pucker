require "spec_helper"

module Pucker
  describe Game do
    it "should create a dealer" do
      Dealer.should_receive(:new)
      Game.new
    end

    describe "#players" do
      it "should have 5 items by default" do
        game = Game.new
        game.players.should have(5).items
      end
    end
  end
end
