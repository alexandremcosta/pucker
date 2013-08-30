require "spec_helper"

module Pucker
  describe PlayerGroup do
    describe "#create_players" do
      it "should create players as resquested" do
        group = PlayerGroup.new
        group.create_players(5)
        group.should have(5).items
      end
    end
  end
end

