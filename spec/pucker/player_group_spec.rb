require "spec_helper"
require "ostruct"

module Pucker
  describe PlayerGroup do
    let(:players) { PlayerGroup.new }

    describe "#[]" do
      it "should delegate to container" do
        puts players.instance_variable_get("@container")
        players[1].should == players.instance_variable_get("@container")[1]
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

    describe "#reset" do
      it "shouldnt change players size" do
        size = players.size
        players.reset
        players.size.should == size
      end

      context "when one player has no stack" do
        it "should substitute this player" do
          first_player = players.first
          first_player.stub(:stack).and_return(0)
          players.reset
          players.should_not include first_player
          players.each do |player|
            player.stack.should > 0
          end
        end
      end
    end
  end
end

