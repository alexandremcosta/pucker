require "spec_helper"
require "ostruct"

module Pucker
  describe PlayerGroup do
    describe "#create_players" do
      it "should create players as resquested" do
        group = PlayerGroup.new
        group.create_players(5)
        group.should have(5).items
      end
    end

    describe "#set_hands" do
      it "should give 2 cards to each player" do
        players = PlayerGroup.new
        players.create_players(2)
        dealer = OpenStruct.new(deal: :card)
        players.each do |p|
          p.should_receive(:set_hand).with(:card, :card)
        end
        players.set_hands(dealer)
      end
    end
  end
end

