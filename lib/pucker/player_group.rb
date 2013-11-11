require_relative 'players'
require 'forwardable'

module Pucker
  class PlayerGroup
    include Enumerable
    extend Forwardable
    def_delegators :@container, :each, :map, :[], :rotate, :rotate!, :size, :last, :first

    def initialize(count=NUM_PLAYERS, amount=STACK)
      @count = count.is_a?(Integer) ? count : NUM_PLAYERS
      @amount = amount.is_a?(Integer) ? amount : STACK
      @container = Array.new(@count) { player_source.call(@amount) }
    end

    def set_hands(dealer)
      @container.each do |player|
        player.set_hand(dealer.deal, dealer.deal)
      end
    end

    def eligible
      @container.select{|p| p.active? || p.allin? }
    end

    def reset
      @container.delete_if{|p| p.stack <= 0}
      while @container.size < @count do
        @container.unshift(player_source.call(@amount))
      end
      @container.each{|p| p.reset_round_state}
    end

    private
    def player_source
      @player_source ||= DummyPlayer.public_method(:new)
    end
  end
end
