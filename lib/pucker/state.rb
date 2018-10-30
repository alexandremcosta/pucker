module Pucker
  class State
    attr_reader :total_players, :position, :min_bet, :table_cards
     
    def initialize(total_players: NUM_PLAYERS, position: 0, min_bet: 0, table_cards: [])
      @total_players = total_players
      @position      = position
      @min_bet       = min_bet
      @table_cards   = table_cards
    end
  end
end
