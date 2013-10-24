require 'java'
java_import 'table.HandEvaluator'

require_relative 'dealer'
require_relative 'player_group'

module Pucker
  class Game
    attr_reader :players

    def initialize(count=NUM_PLAYERS, amount=STACK)
      count = NUM_PLAYERS unless count.is_a? Integer
      amount = STACK unless amount.is_a? Integer
      @players = PlayerGroup.new(count, amount)
    end

    def play
      setup_game
      pot = collect_blinds
      deal_flop
      pot += collect_bets
      deal_turn
      pot += collect_bets
      deal_river
      pot += collect_bets
      winners = evaluate_winners
      reward(winners, pot)
    end

    private
    def dealer
      @dealer ||= Dealer.new
    end

    def setup_game
      table_cards.clear
      dealer.reset
      players.rotate!
      players.set_hands(dealer)
    end

    def collect_blinds
      pot = 0
      players.each do |p|
        pot += p.get_from_stack(BIG_BLIND)
      end
      return pot
    end

    def collect_bets
      pot = max_bet = first_player = 0
      new_round = true

      while new_round
        new_round = false

        players.rotate(first_player).each_with_index do |p, i|
          last_bet = p.bet(max_bet) if p.active?

          if last_bet && last_bet > max_bet # In case of raise
            max_bet = last_bet
            first_player = i + 1
            new_round = true

            break
          end
        end
      end
      return pot
    end

    def deal_flop
      3.times do deal_table_card end
    end

    def deal_turn
      deal_table_card
    end

    def deal_river
      deal_table_card
    end

    def deal_table_card
      table_cards << dealer.deal
    end

    def evaluate_winners
      rank = {}
      max = 0

      players.each do |p|
        rank[p] = HandEvaluator.rank_hand(p.full_hand(table_cards))
        max = rank[p] if rank[p] > max
      end

      winners = rank.select {|player, rank| rank == max}
      return winners.keys
    end

    def reward(winners, pot)
      prize = pot / winners.size
      winners.each do |player| player.reward(prize) end
    end

    def table_cards
      @table_cards ||= []
    end
  end
end
