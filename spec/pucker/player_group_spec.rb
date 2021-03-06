require "spec_helper"
require "ostruct"

module Pucker
  describe PlayerGroup do
    let(:players) { PlayerGroup.new }

    describe "#[]" do
      it "should delegate to container" do
        expect(players[1]).to be players.instance_variable_get("@container")[1]
      end
    end

    describe "#set_hands" do
      it "should give 2 cards to each player" do
        dealer = OpenStruct.new(deal: :card)
        players.each do |p|
          expect(p).to receive(:set_hand).with(:card, :card)
        end
        players.set_hands(dealer)
      end
    end

    describe "#reset" do
      it "shouldnt change players size" do
        size = players.size
        players.reset
        expect(players.size).to be size
      end

      context "when players have ZERO stack" do
        it "should increase back its stack"  do
          players.first.stack = 0
          players.last.stack = 0
          players.reset
          players.each do |player|
            expect(player.stack).to be > 0
          end
        end
      end
    end
  end
end

