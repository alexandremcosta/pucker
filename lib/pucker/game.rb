# Email: alexandremcost at gmail dot com
# Author: Alexandre Marangoni Costa
#
# Responsible for orchestrating the game. Get Cards from the Dealer, give to Players,
# collect bets from players, reward winners, register logs and statistics and sets everything up
# for a new round.

require_relative 'state'
require_relative 'dealer'
require_relative 'player_group'
require_relative 'pot'
require_relative 'multi_logger'
require_relative 'bn_players'

module Pucker
  class Game
    attr_reader :players

    def initialize(count=NUM_PLAYERS, amount=STACK)
      @players = PlayerGroup.new(count, amount)
    end

    def play
      setup_game
      collect_blinds

      deal_flop
      LOG.debug("FLOP")
      main_pot.merge(collect_bets)

      deal_turn
      LOG.debug("TURN")
      main_pot.merge(collect_bets)

      deal_river
      LOG.debug("RIVER")
      main_pot.merge(collect_bets)

      if players.eligible.empty?
        LOG.error("No eligible players")
        return false
      end

      winners = eligible_players_by_rank
      LOG.info(" ")
      LOG.info("TABLE CARDS: #{@table_cards.map{|c| c.toString}.join('  ')}")
      # LOG.info("POT:\n#{main_pot}")
      # LOG.info("# of 1st winners: #{winners.first.count}")
      LOG.info("PLAYERS: #{winners.flatten.map{|p| [p.id, "[#{p.stack}]", p.hand.toString.strip].join(' ')}.join('  |  ')}")
      reward winners
      LOG.info("GAME STATE: #{players.map{|p| "#{p.id}: #{p.stack}"}.join('  |  ')}\n")
      register_statistic
      return true
    end

    private
    def dealer
      @dealer ||= Dealer.new
    end

    def main_pot
      @pot ||= Pot.new(@players.size)
    end

    def setup_game
      @table_cards = []
      main_pot.reset
      dealer.reset
      prepare_players
    end

    def prepare_players
      players.rotate!
      players.reset
      players.set_hands(dealer)
    end

    def collect_blinds
      players.each do |p|
        amount = p.get_from_stack(BIG_BLIND)
        main_pot.add_bet(player_position(p), round, amount)
      end
    end

    def collect_bets
      max_bet = 0
      last_player = previous_player =  players.last
      round_pot = Pot.new(players.size)

      players.cycle do |player|
        break if !players.has_multiple_active?

        state = new_state(players.eligible.count, players.eligible.index(player), max_bet)
        last_bet = player.bet_if_active(state)

        if last_bet
          if last_bet > max_bet #RAISED
            max_bet = last_bet
            last_player = previous_player
          end

          old_bets = round_pot.total_contributed_by(player_position(player))
          player.reward(old_bets)
          LOG.debug("PLAYER: #{player} - BET: #{last_bet - old_bets}")
          round_pot.add_bet(player_position(player), round, last_bet - old_bets)
        end

        previous_player = player
        break if player == last_player
      end

      return round_pot
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

    # according to: http://stackoverflow.com/questions/5462583/poker-side-pot-algorithm
    def eligible_players_by_rank
      players.eligible.sort_by do |p| p.hand_rank(@table_cards)
      end.reverse.group_by do |p| p.hand_rank(@table_cards)
      end.each do |rank, people|
        people.sort_by! do |p| main_pot.total_contributed_by(player_position(p)) end
      end.values
    end

    # according to: http://stackoverflow.com/questions/5462583/poker-side-pot-algorithm
    def reward(winners)
      winners.each do |tied_players|
        while tied_players.any? do
          player = tied_players.first
          amount = main_pot.total_contributed_by(player_position(player))
          prize = main_pot.get_from_all(amount) / tied_players.size
          tied_players.each do |p| p.reward(prize) end
          tied_players.shift
          return if main_pot.empty?
        end
      end
    end

    def register_statistic
      players.each do |p|
        STATISTIC.increase_high_stack(p) if p.stack > STACK
      end
      STATISTIC.increase_table_king(players.get_table_king)
    end

    def round
      case @table_cards.size
      when 0
        :preflop
      when 3
        :flop
      when 4
        :turn
      when 5
        :river
      else
        raise 'invalid table round'
      end
    end

    def player_position(player)
      players.index(player)
    end

    def new_state(total_players, position, max_bet)
      State.new(
        total_players: total_players,
        position: position,
        min_bet: max_bet,
        table_cards: @table_cards,
        pot: main_pot)
    end
  end
end
