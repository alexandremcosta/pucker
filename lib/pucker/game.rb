require 'java'
java_import 'table.HandEvaluator'

require_relative 'dealer'
require_relative 'player_group'
require_relative 'pot'

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
      collect_blinds
      deal_flop
      collect_bets
      deal_turn
      collect_bets
      deal_river
      collect_bets
      winners = evaluate_winners
      #reward(winners, pot)
    end

    private
    def dealer
      @dealer ||= Dealer.new
    end

    def setup_game
      table_cards.clear
      dealer.reset
      pot.reset
      prepare_players
    end

    def prepare_players
      players.delete_if{|p| p.stack <= 0}
      players.each{|p| p.reset_round_state}
      players.rotate!
      players.set_hands(dealer)
    end

    def collect_blinds
      players.each do |p|
        amount = p.get_from_stack(BIG_BLIND)
        pot.add_bet(p, amount)
      end
    end

    def collect_bets
      max_bet = 0
      last_player = previous_player =  players.last

      players.cycle do |player|
        last_bet = player.bet_if_active(max_bet)

        if last_bet
          if last_bet > max_bet #RAISED
            max_bet = last_bet
            last_player = previous_player
          end
          pot.add_bet(player, last_bet)
        end

        previous_player = player
        break if player == last_player
      end
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

    #def reward(winners, pot)
    #  prize = pot / winners.size
    #  winners.each do |player| player.reward(prize) end
    #end

    def table_cards
      @table_cards ||= []
    end

    def pot
      @pot ||= Pot.new
    end
  end
end
