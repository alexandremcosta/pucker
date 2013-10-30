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

    def reset
      @all_bets = Hash.new
    end

    def contributors
      all_bets.keys
    end
  end
end
