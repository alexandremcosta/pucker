require_relative 'concerns/insert_multiple'
require 'java'
java_import 'table.Hand'

module Pucker
  class State < ActiveRecord::Base
    include InsertMultiple

    attr_reader :table_cards

    def self.create_multiple(collection)
      return if collection.empty?

      fields = collection.first.poker_attributes.keys
      values = collection.map{|s| s.poker_attributes.values}

      insert_multiple(fields, values)
    end

    def self.build(
      total_players: NUM_PLAYERS,
      table_cards: [],
      position: 0,
      position_over_all: 0,
      min_bet: 0,
      player: '',
      hand: Hand.new,
      pot: Pot.new(NUM_PLAYERS))

      state = State.new(total_players: total_players, position: position, position_over_all: position_over_all, min_bet: min_bet, player: player)
      state.total_pot = pot.total
      state.set_cards(table_cards, hand)
      state.set_amount(pot)
      state.set_raises(pot)

      return state
    end

    def predict_params
      discard = case table_cards.size
      when 3
        %w(turn_rank turn_suit river_rank river_suit)
      when 4
        %w(river_rank river_suit)
      else
        %w(ppot npot)
      end
      discard += %w(reward player id)
      attributes.reject{|k, _| discard.include?(k.to_s)}
    end

    def set_raises(pot)
      initialize_raises

      count_round_raises(pot, :flop)  if table_cards.size >= 3
      count_round_raises(pot, :turn)  if table_cards.size >= 4
      count_round_raises(pot, :river) if table_cards.size == 5
    end

    def set_amount(pot)
      self.player1_amount = pot.total_contributed_by(0)
      self.player2_amount = pot.total_contributed_by(1)
      self.player3_amount = pot.total_contributed_by(2)
      self.player4_amount = pot.total_contributed_by(3)
      self.player5_amount = pot.total_contributed_by(4)

      self.self_amount = self.attributes["player#{self.position_over_all+1}_amount"]
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
        if amount == self.min_bet # check
          self.decision_check = amount
        else # raise
          self.decision_raise = amount
        end
      else # false = fold
        self.decision_fold = 1
      end
    end

    def poker_attributes
      attributes.except('id')
    end

    private

    def count_round_raises(pot, round)
      max_bet = 0
      all_bets = pot.all_bets
      max_index = all_bets.map{|bets| bets[round].size}.max

      (0...max_index).each do |bet_index|
        all_bets.each_with_index do |player_bets, player_index|
          bet = player_bets[round][bet_index] || 0
          if bet > max_bet
            max_bet = bet
            value = attributes["player#{player_index+1}_raises"]
            self.send("player#{player_index+1}_raises=", value + 1)
          end
        end
      end

      self.self_raises = self.attributes["player#{self.position_over_all+1}_raises"]
    end

    def initialize_raises
      self.player1_raises = 0
      self.player2_raises = 0
      self.player3_raises = 0
      self.player4_raises = 0
      self.player5_raises = 0
    end
  end
end
