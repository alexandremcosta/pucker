require_relative 'players'
require 'forwardable'

module Pucker
  class PlayerGroup
    include Enumerable

    extend Forwardable
    def_delegators :container, :each, :[], :rotate, :rotate!

    attr_reader :container

    def initialize(count=NUM_PLAYERS, amount=STACK)
      count = NUM_PLAYERS unless count.is_a? Integer
      amount = STACK unless amount.is_a? Integer
      @container = Array.new(count) { player_source.call(amount) }
    end

    def set_hands(dealer)
      @container.each do |player|
        player.set_hand(dealer.deal, dealer.deal)
      end
    end

    private
    def player_source
      @player_source ||= Player.public_method(:new)
    end
  end
end
