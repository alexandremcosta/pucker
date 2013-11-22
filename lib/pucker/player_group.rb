require_relative 'players'
require 'forwardable'

module Pucker
  class PlayerGroup
    include Enumerable
    extend Forwardable
    def_delegators :@container, :each, :map, :[], :rotate, :rotate!, :size, :last, :first, :index

    def initialize(count=NUM_PLAYERS, amount=STACK)
      @count = count.is_a?(Integer) ? count : NUM_PLAYERS
      @amount = amount.is_a?(Integer) ? amount : STACK
      @container = Array.new(@count-1) { player_source.call(@amount) }
      @container << BestBnPlayer.new(@amount)
    end

    def set_hands(dealer)
      @container.each do |player|
        player.set_hand(dealer.deal, dealer.deal)
      end
    end

    def eligible
      @container.select{|p| p.active? || p.allin? }
    end

    def has_multiple_active?
      @container.select{|p| p.active?}.size > 1
    end

    def reset
      @container.each do |p|
        if p.stack <= 0
          p.stack = @amount
          LOG.info("#{p.id} lost")
          STATISTIC.increase_losses(p)
        end
      end
      @container.each{|p| p.reset_round_state}
    end

    private
    def player_source
      @player_source ||= SimpleBnPlayer.public_method(:new)
    end
  end
end
