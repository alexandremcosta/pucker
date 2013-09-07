require "spec_helper"
require "ostruct"

module Pucker
  describe PlayerGroup do
    let(:players) { PlayerGroup.new }

    describe "#[]" do
      it "should delegate to container" do
        players[1].should == players.container[1]
      end
    end

    describe "#set_hands" do
      it "should give 2 cards to each player" do
        dealer = OpenStruct.new(deal: :card)
        players.each do |p|
          p.should_receive(:set_hand).with(:card, :card)
        end
        players.set_hands(dealer)
      end
    end
  end
end

