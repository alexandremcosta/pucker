# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Implements a container of players. A PlayerGroup behave similarly Enumerable, which is a
# tipical Ruby collection design pattern implementation. In adittion, it handles the dealing
# phase of the game, getting cards from dealer and giving to players. It also knows the
# eligible players for a round, who is the player with the most amount in stack, and rebuys
# stack for losers.

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
      @container = Array.new(@count-1) { player_source.new(@amount) }
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

    def get_table_king
      @container.max_by{ |p| p.stack }
    end

    private
    def player_source
      [SimpleBnPlayer, BnPlayer, Player].sample
    end
  end
end
