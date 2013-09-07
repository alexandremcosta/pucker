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
      pot = collect_bets_from(2) # from UTGs to bigblind
      deal_flop
      pot += collect_bets_from(0) # from smallblind to UTGs
      deal_turn
      pot += collect_bets_from(0) # from smallblind to UTGs
      deal_river
      pot += collect_bets_from(0) # from smallblind to UTGs
      #winners = evaluate_winners
      #reward(winners, pot)
    end

    private
    def dealer
      @dealer ||= Dealer.new
    end

    def setup_game
      @table_cards = []
      dealer.reset
      players.rotate!
      players.set_hands(dealer)
    end

    def collect_blinds
      players[0].get_from_stack(SMALL_BLIND) + players[1].get_from_stack(BIG_BLIND)
    end

    def collect_bets_from(first_player)
      pot = 0
      players.rotate(first_player).each do |p|
        pot += p.bet if p.active?
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
      @table_cards << dealer.deal
    end

    def evaluate_winners

    end
  end
end
