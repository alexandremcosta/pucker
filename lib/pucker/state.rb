module Pucker
  class State
    attr_reader :total_players, :position, :min_bet, :table_cards

    def initialize(
      total_players: NUM_PLAYERS,
      table_cards: [],
      position: 0,
      min_bet: 0,
      pot: Pot.new(NUM_PLAYERS))

      @total_players = total_players
      @table_cards   = table_cards
      @position      = position
      @min_bet       = min_bet
      @pot           = pot
    end
  end
end
