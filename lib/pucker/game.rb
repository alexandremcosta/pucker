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

module Pucker
  class Game
    attr_reader :players

    def initialize
      @players = PlayerGroup.new
    end

    def play
      setup_game
      collect_blinds

      # FLOP
      3.times do deal_table_card end
      LOG.debug("FLOP")
      main_pot.merge!(collect_bets)

      # TURN
      deal_table_card
      LOG.debug('')
      LOG.debug("TURN")
      main_pot.merge!(collect_bets)

      # RIVER
      deal_table_card
      LOG.debug('')
      LOG.debug("RIVER")
      main_pot.merge!(collect_bets)

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
      rotate_and_reset_states
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
      players.set_hands(dealer)
    end

    def rotate_and_reset_states
      players.rotate!
      players.reset
    end

    def collect_blinds
      players.each do |p|
        amount = p.get_from_stack(BIG_BLIND)
        main_pot.add_bet(player_position(p), round, amount)
      end
    end

    def collect_bets
      old_bets = 0
      max_bet = 0
      has_allin = false
      last_player = previous_player = players.last
      round_pot = Pot.new(players.size)

      players.cycle do |player|
        break if !players.has_multiple_active? && !has_allin


        if player.active?
          state = new_state(players.eligible.count, players.eligible.index(player), player_position(player), max_bet, player.hand, main_pot.merge(round_pot), player.id)

          if player_bet = player.bet_and_store(state)
            if player.allin? && (player_bet + round_pot.total_contributed_by(player_position(player))) > max_bet
              max_bet = player_bet + round_pot.total_contributed_by(player_position(player))
              last_player = previous_player
            elsif player_bet > max_bet #RAISED
              max_bet = player_bet
              last_player = previous_player
            end

            if player.allin?
              LOG.debug("\t\t\t\t\t----------------------> ALLIN!")
              has_allin = true
              old_bets = 0
            else
              old_bets = round_pot.total_contributed_by(player_position(player))
              player.reward(old_bets)
            end

            LOG.debug("PLAYER: #{player} - BET: #{player_bet - old_bets}")
            round_pot.add_bet(player_position(player), round, player_bet - old_bets)
          else
            LOG.debug("PLAYER: #{player} - FOLD")
          end
        end

        previous_player = player
        break if player == last_player
      end

      return round_pot
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

    def new_state(total_players, position, position_over_all, max_bet, hand, pot, player)
      State.build(
        total_players: total_players,
        table_cards: @table_cards,
        position: position,
        position_over_all: position_over_all,
        min_bet: max_bet,
        player: player,
        hand: hand,
        pot: pot)
    end
  end
end
