# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Pot accumulates every bet a player makes. It knows how to merge itself with another Pot and
# to reset all bets. It also knows how to print itself.

module Pucker
  class Pot
    attr_accessor :all_bets

    def initialize(n_players)
      @n_players = n_players
      reset
    end

    def add_bet(player, round, amount)
      all_bets[player][round] << amount
    end

    def merge(other_pot)
      bets = merge_bets(other_pot)
      self.class.new(@n_players).tap {|pot| pot.all_bets = bets}
    end


    def merge!(other_pot)
      @all_bets = merge_bets(other_pot)
      self
    end

    def total_contributed_by(index)
      total = 0
      all_bets[index].each do |round, bets|
        total += bets.sum
      end
      total
    end

    def total
      total = 0
      (0...@n_players).each do |i|
        total += total_contributed_by(i)
      end
      total
    end

    def get_from_all(amount)
      total = 0

      all_bets.each_with_index do |bets, index|
        contributed = total_contributed_by(index)
        to_subtract = [contributed, amount].min
        get_from(index, to_subtract)
        total += to_subtract
      end

      return total
    end

    def get_from(index, amount)
      bets = @all_bets[index]
      bets.keys.reverse.each do |round|
        break if amount <= 0
        round_bets = bets[round].sum

        if round_bets >= amount
          bets[round] = [round_bets - amount]
          amount = 0
        else
          bets[round] = [0]
          amount = amount - round_bets
        end
      end
    end

    def reset
      @all_bets = Array.new(@n_players) { Hash.new {|h, k| h[k] = []} }
    end

    def empty?
      @all_bets.each do |player_bets|
        sum = player_bets.values.flatten.sum
        return false if sum > 0
      end

      return true
    end

    def to_s
      str = ''
      all_bets.each_with_index do |bet, index|
        str << "Player position #{index}" + ': ' + bet.to_s + "\n"
      end
      return str
    end

    private
    def merge_bets(other_pot)
      raise 'invalid pot merge' if other_pot.all_bets.size != @all_bets.size

      all_bets.map.with_index do |player_bets, index|
        player_bets.merge(other_pot.all_bets[index])
      end
    end
  end
end
