# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Pot accumulates every bet a player makes. It knows how to merge itself with another Pot and
# to reset all bets. It also knows how to print itself.

module Pucker
  class Pot
    attr_accessor :all_bets

    def initialize
      reset
    end

    def add_bet(player, amount)
      all_bets[player] ||= 0
      all_bets[player] += amount
    end

    def sum(other_pot)
      new_bets = self.all_bets.merge(other_pot.all_bets) do |player, self_bet, other_bet|
        self_bet + other_bet
      end
      new_pot = Pot.new
      new_pot.all_bets = new_bets
      return new_pot
    end
    alias :+ :sum

    def total_contributed_by(player)
      all_bets[player]
    end

    def get_from_all(amount)
      total = 0
      all_bets.each do |player, bet|
        to_sub = if bet < amount then bet else amount  end
        all_bets[player] -= to_sub
        total += to_sub
      end
      return total
    end

    def reset
      @all_bets = Hash.new(0)
    end

    def empty?
      @all_bets.each { |p, b| return false if b > 0 }
      return true
    end

    def to_s
      str = ''
      all_bets.each do |player, bet|
        str << player.id + ': ' + bet.to_s + " | "
      end
      return str
    end
  end
end
