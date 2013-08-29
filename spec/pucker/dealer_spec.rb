require "spec_helper"

module Pucker
  describe Dealer do
    describe "#deal" do
      let(:dealer) { Dealer.new }

      it "deals cards" do
        dealer.deal.should be_an_instance_of Java::Table::Card
      end

      it "deals 52 different cards" do
        cards = []
        52.times do cards << dealer.deal end
        cards.uniq.should == cards
      end

      it "doesn't deal 53 cards" do
        52.times do dealer.deal end
        dealer.deal.should be_false
      end
    end
  end
end
