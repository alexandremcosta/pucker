require_relative 'dealer'
require_relative 'player_group'

module Pucker
  class Game
    def initialize(num_of_players = 5)
      players.create_players(num_of_players)
    end

    def play
      #deal
      #pot = collect_bets_pre_flop
      #deal_flop
      #pot += collect_bets
      #deal_turn
      #pot += collect_bets
      #deal_river
      #pot += collect_bets
      #winners = evaluate_winners
      #reward(winners, pot)
    end

    def players
      @player_group ||= PlayerGroup.new
    end

    private
    def dealer
      @dealer ||= Dealer.new
    end
  end
end
