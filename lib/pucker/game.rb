module Pucker
  class Game
    def initialize(num_of_players = 5)
      @dealer = Dealer.new
      create_players(num_of_players)
    end

    #def play
    #  set_players_position
    #  deal
    #  pot = collect_bets_pre_flop
    #  deal_flop
    #  pot += collect_bets
    #  deal_turn
    #  pot += collect_bets
    #  deal_river
    #  pot += collect_bets
    #  winners = evaluate_winners
    #  reward(winners, pot)
    #end

    def players
      @players
    end

    private
    def create_players(count)
      @players = (1..count).map { player_source.call }
    end

    def player_source
      @player_source ||= Player.public_method(:new)
    end
  end
end
