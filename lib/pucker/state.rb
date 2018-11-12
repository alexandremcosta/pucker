module Pucker
  class State < ActiveRecord::Base
    # attr_reader :total_players, :position, :min_bet, :table_cards

    # def initialize(
    #   total_players: NUM_PLAYERS,
    #   table_cards: [],
    #   position: 0,
    #   min_bet: 0,
    #   pot: Pot.new(NUM_PLAYERS))

    #   @total_players = total_players
    #   @table_cards   = table_cards
    #   @position      = position
    #   @min_bet       = min_bet
    #   @pot           = pot
    # end

    private
    def set_total_pot
      @total_pot = @pot.total
    end

    def set_cards(player)
      @card1_rank = player.get_card(1).rank
      @card1_suit = player.get_card(1).suit
      @card2_rank = player.get_card(2).rank
      @card2_suit = player.get_card(2).suit
      @flop1_rank = @table_cards[0].rank
      @flop1_suit = @table_cards[0].suit
      @flop2_rank = @table_cards[1].rank
      @flop2_suit = @table_cards[1].suit
      @flop3_rank = @table_cards[2].rank
      @flop3_suit = @table_cards[2].suit
      @turn_rank  = @table_cards[3].rank
      @turn_suit  = @table_cards[3].suit
      @river_rank = @table_cards[4].rank
      @river_suit = @table_cards[4].suit
    end
  end

  def set_decision(amount)
    @decision_fold = 0
    @decision_check = 0
    @decision_raise = 0

    if amount
      if amount == @min_bet # check
        @decision_check = amount
      else # raise
        @decision_raise = amount
      end
    else # false = fold
      @decision_fold = 1
    end
  end

  def set_player_bets(player)
    #TODO
  end
end
