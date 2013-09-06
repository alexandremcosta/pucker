require_relative 'dealer'
require_relative 'player_group'

module Pucker
  class Game
    attr_reader :players

    def initialize(count=5)
      count = 5 unless count.is_a? Integer
      @players = PlayerGroup.new(count)
    end

    def play
      setup_game
      pot = collect_blinds
      pot = collect_bets_from(2) # from UTG-1 to bigblind
      deal_flop
      pot += collect_bets_from(0) # from smallblind
      deal_turn
      pot += collect_bets_from(0) # from smallblind
      deal_river
      pot += collect_bets_from(0) # from smallblind
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
      players.rotate_positions
      players.set_hands(dealer)
    end

    def collect_bets_from(first_player)
      pot = 0
      players.rotate(first_player).each do |p|
        pot += player.bet if player.active?
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
  end

end
