require 'forwardable'
require_relative 'player'

module Pucker
  class PlayerGroup
    include Enumerable

    extend Forwardable
    def_delegators :container, :each

    attr_reader :container

    def initialize(count=5)
      count = 5 unless count.is_a? Integer
      @container = Array.new(count) { player_source.call }
    end

    def set_hands(dealer)
      @container.each do |player|
        player.set_hand(dealer.deal, dealer.deal)
      end
    end

    def rotate_positions
      @container.rotate!
    end

    private
    def player_source
      @player_source ||= Player.public_method(:new)
    end
  end
end
