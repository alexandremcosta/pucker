require "spec_helper"

module Pucker
  describe Dealer do
    let(:dealer) { Dealer.new }

    describe "#deal" do
      it "deals cards" do
        expect(dealer.deal).to be_instance_of Java::Table::Card
      end

      it "deals 52 different cards" do
        cards = []
        52.times do cards << dealer.deal end
        expect(cards.uniq).to eq(cards)
      end

      it "doesn't deal 53 cards" do
        52.times do dealer.deal end
        expect(dealer.deal).to be_falsey
      end
    end

    describe "#reset" do
      it "allows dealer to continue dealing" do
        52.times do dealer.deal end
        dealer.reset
        expect(dealer.deal).to be_instance_of Java::Table::Card
      end

      it "should deal cards in different order" do
        first_card = dealer.deal
        second_card = dealer.deal
        dealer.reset
        expect(dealer.deal).not_to eq(first_card)
        expect(dealer.deal).not_to eq(second_card)
      end
    end
  end
end
