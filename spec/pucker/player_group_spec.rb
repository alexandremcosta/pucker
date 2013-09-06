require "spec_helper"
require "ostruct"

module Pucker
  describe PlayerGroup do
    describe "#set_hands" do
      it "should give 2 cards to each player" do
        players = PlayerGroup.new
        dealer = OpenStruct.new(deal: :card)
        players.each do |p|
          p.should_receive(:set_hand).with(:card, :card)
        end
        players.set_hands(dealer)
      end
    end
  end
end

