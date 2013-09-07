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
    
    describe "#play" do
      pending("deciding what to spec out")
    end

    describe "private methods" do
      describe "#collect_blinds" do
        subject { Game.new.send(:collect_blinds) }
        it { should == 30 }
      end
    end
  end
end
