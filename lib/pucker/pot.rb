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
    
    def total_contributed_by(player)
      all_bets[player]
    end

    def get_from_all(amount)
      total = 0
      all_bets.each do |player, bet|
        to_sub = if bet - amount < 0
          bet
        else
          amount
        end
        all_bets[player] -= to_sub
        total += to_sub
      end
      return total
    end

    def reset
      @all_bets = Hash.new
    end

    def contributors
      all_bets.keys
    end
  end
end