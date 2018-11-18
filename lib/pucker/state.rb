require 'java'
java_import 'table.Hand'

module Pucker
  class State < ActiveRecord::Base
    attr_reader :table_cards

    def self.build(
      total_players: NUM_PLAYERS,
      table_cards: [],
      position: 0,
      min_bet: 0,
      hand: Hand.new,
      pot: Pot.new(NUM_PLAYERS))

      state = State.new(total_players: total_players, position: position, min_bet: min_bet)
      state.total_pot = pot.total
      state.set_cards(table_cards, hand)
      state.set_amount(pot)
      state.set_raises(pot)

      return state
    end

    def set_raises(pot)
      count_round_raises(pot, :river) if table_cards.size == 5
      count_round_raises(pot, :turn)  if table_cards.size >= 4
      count_round_raises(pot, :flop)  if table_cards.size >= 3
    end

    def count_round_raises(pot, round)
      max_bet = 0
      bet_index = 0
      all_bets = pot.all_bets
      max_index = all_bets.map{|bets| bets[round].size}.max

      initialize_raises

      (0...max_index).each do |index|
        all_bets.each do |player_bets|
          bet = player_bets[round][index] || 0
          if bet > max_bet
            max_bet = bet
            value = instance_variable_get("@player#{index+1}_raises") || 0
            instance_variable_set("@player#{index+1}_raises", value + 1)
          end
        end
      end
    end

    def set_amount(pot)
      self.player1_amount = pot.total_contributed_by(0)
      self.player2_amount = pot.total_contributed_by(1)
      self.player3_amount = pot.total_contributed_by(2)
      self.player4_amount = pot.total_contributed_by(3)
      self.player5_amount = pot.total_contributed_by(4)
    end

    def set_cards(table_cards, hand)
      @table_cards = table_cards

      self.card1_rank = hand.get_card(1).rank rescue nil
      self.card1_suit = hand.get_card(1).suit rescue nil
      self.card2_rank = hand.get_card(2).rank rescue nil
      self.card2_suit = hand.get_card(2).suit rescue nil

      self.flop1_rank = table_cards[0].rank rescue nil
      self.flop1_suit = table_cards[0].suit rescue nil
      self.flop2_rank = table_cards[1].rank rescue nil
      self.flop2_suit = table_cards[1].suit rescue nil
      self.flop3_rank = table_cards[2].rank rescue nil
      self.flop3_suit = table_cards[2].suit rescue nil
      self.turn_rank  = table_cards[3].rank rescue nil
      self.turn_suit  = table_cards[3].suit rescue nil
      self.river_rank = table_cards[4].rank rescue nil
      self.river_suit = table_cards[4].suit rescue nil
    end

    def set_decision(amount)
      self.decision_fold = 0
      self.decision_check = 0
      self.decision_raise = 0

      if amount
        if amount == @min_bet # check
          self.decision_check = amount
        else # raise
          self.decision_raise = amount
        end
      else # false = fold
        self.decision_fold = 1
      end
    end

    private
    def initialize_raises
      self.player1_raises = 0
      self.player2_raises = 0
      self.player3_raises = 0
      self.player4_raises = 0
      self.player5_raises = 0
    end
  end
end
