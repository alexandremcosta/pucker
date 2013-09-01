require "spec_helper"

module Pucker
  describe Dealer do
    let(:dealer) { Dealer.new }

    describe "#deal" do
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

    describe "#reset" do
      it "allows dealer to continue dealing" do
        52.times do dealer.deal end
        dealer.reset
        dealer.deal.should be_an_instance_of Java::Table::Card
      end
      
      it "should deal cards in different order" do
        first_card = dealer.deal
        second_card = dealer.deal
        dealer.reset
        dealer.deal.should_not == first_card
        dealer.deal.should_not == second_card
      end
    end
  end
end
