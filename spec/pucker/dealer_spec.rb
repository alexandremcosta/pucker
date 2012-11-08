require "spec_helper"

module Pucker

  describe Dealer do
    describe "#deal" do
      before(:each) do
        @dealer = Dealer.new
      end

      it "deals cards" do
        @dealer.deal.should be_an_instance_of Java::Table::Card
      end

      it "deals 52 different cards" do
        cards = (1..52).map{ @dealer.deal.getIndex }
        cards.uniq.should have(52).cards
      end

      it "don't deals 53 cards" do
        52.times { @dealer.deal }
        @dealer.deal.should be_false
      end
    end
  end
end
