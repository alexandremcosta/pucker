require_relative 'dealer'
require_relative 'player_group'
require_relative 'pot'
require_relative 'multi_logger'

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

      if players.eligible.empty?
        LOG.error("No eligible players") 
        return false
      end

      winners = eligible_players_by_rank
      LOG.info("POT: #{pot}")
      LOG.info("TABLE CARDS: #{table_cards.map{|c| c.toString}}")
      LOG.info("WINNERS BEFORE REWARD: #{winners.flatten.map{|p| [p.id, p.hand.toString, p.stack]}}")
      reward winners
      LOG.info("PLAYERS AFTER REWARD: #{players.map{|p| [p.id, p.hand.toString, p.stack]}}")
      return true
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
      players.rotate!
      players.reset
      players.set_hands(dealer)
    end

    def pot
      @pot ||= Pot.new
    end

    def table_cards
      @table_cards ||= []
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
        break if players.eligible == 1
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

    # according to: http://stackoverflow.com/questions/5462583/poker-side-pot-algorithm
    def eligible_players_by_rank
      players.eligible.sort_by do |p| p.hand_rank(table_cards)
      end.reverse.group_by do |p| p.hand_rank(table_cards)
      end.each do |rank, people|
        people.sort_by! do |p| pot.total_contributed_by(p) end
      end.values
    end

    # according to: http://stackoverflow.com/questions/5462583/poker-side-pot-algorithm
    def reward(winners)
      winners.each do |tied_players|
        while tied_players.any? do
          player = tied_players.first
          amount = pot.total_contributed_by(player)
          prize = pot.get_from_all(amount) / tied_players.size
          tied_players.each do |p| p.reward(prize) end
          tied_players.shift
          return if pot.empty?
        end
      end
    end
  end
end
