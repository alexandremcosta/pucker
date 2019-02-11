# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Implements trivial players. Player class always checks. DummyPlayer class bets randomly.

require_relative 'sequence'
require 'java'
java_import 'table.Card'
java_import 'table.Hand'
java_import 'table.HandEvaluator'

module Pucker
  class Player
    attr_accessor :stack
    attr_reader :id

    def initialize(amount=STACK)
      @round_states = []
      @all_states = []
      @active = true
      @allin = false
      @initial_round_stack = @stack = amount
      @id = self.class.name.split('::').last + Sequence.next.to_s
    end

    def get_from_stack(amount)
      if @stack <= amount
        inactive!
        allin!
        tmp = @stack
        @stack = 0
        return tmp
      else
        @stack -= amount
        return amount
      end
    end

    def bet_and_store(state)
      set_hand_status(state)
      amount = bet(state)
      state.set_decision(amount)
      @round_states << state
      amount
    end

    def bet(state)
      raise 'This is an abstract class. Override this method to create a player.'
    end

    def active?
      @active
    end

    def allin?
      @allin
    end

    def hand
      @hand ||= Hand.new
    end

    def set_hand(card1, card2)
      reset_hand
      hand.add_card(card1)
      hand.add_card(card2)
    end

    def reward(price)
      @stack += price
    end

    def reset_round_state
      store_state_reward(@stack - @initial_round_stack)
      @initial_round_stack = @stack
      @active = true
      @allin  = false
    end

    def fold
      inactive!
    end

    def to_s
      "#{id.rjust(20, ' ')} -#{hand} - #{stack}"
    end

    def persist_and_clear_states
      State.create_multiple(@all_states)
      @all_states = []
    end

    def hand_rank(table_cards)
      HandEvaluator.rank_hand(full_hand(table_cards))
    end

    protected
    def full_hand(table_cards)
      full_hand = Hand.new(hand)
      table_cards.each do |card| full_hand.add_card(card) end
      return full_hand
    end

    def reset_hand
      @hand = hand.make_empty
    end

    def inactive!
      @active = false
    end

    def allin!
      @allin = true
    end

    def stocastic_raise(min_bet)
      random_choice = rand
      chance = rand(0.8..0.9)

      if random_choice < chance
        raise_from(min_bet)
      else
        get_from_stack(min_bet)
      end
    end

    def stocastic_check(min_bet)
      random_choice = rand
      chance = rand(0.8..0.9)

      if random_choice < chance
        get_from_stack(min_bet)
      else
        raise_from(min_bet)
      end
    end

    def stocastic_fold(min_bet)
      random_choice = rand
      chance = (min_bet <= 2*BIG_BLIND) ? 0.8 : 0.9

      if random_choice < chance
        fold
      else
        get_from_stack(min_bet)
      end
    end

    def raise_from(min_bet)
      min_bet = BIG_BLIND if min_bet == 0

      if stack > (8 * BIG_BLIND) && stack > (4 * min_bet)
        amount = (rand(2.0..3.0) * min_bet).round
        get_from_stack(amount)
      else # ALLIN
        get_from_stack(stack)
      end
    end

    def store_state_reward(reward)
      @round_states.each { |state| state.reward = reward }
      @all_states += @round_states
      @round_states = []
    end

    def set_hand_status(state)
      state.hand_rank = hand_rank(state.table_cards)
      state.ppot, state.npot, state.hand_strength = hand_potential(state.table_cards)
    end

    def hand_potential(table_cards)
      ahead = 0
      behind = 1
      tied = 2

      hp = Array.new(3) { Array.new(3, 0) }
      hp_total = Array.new(3, 0)

      our_rank = hand_rank(table_cards)

      # Consider all two card combinations of the remaining cards for the opponent
      deck = (0..51).to_a
      known_cards = table_cards.map(&:get_index) + [hand.get_card_index(1), hand.get_card_index(2)]
      possible_op_cards = deck - known_cards

      possible_op_cards.combination(2) do |op_card1, op_card2|
        op_hand = Hand.new
        (table_cards + [Card.new(op_card1), Card.new(op_card2)]).each { |card| op_hand.add_card(card) }
        op_rank = HandEvaluator.rank_hand(op_hand)

        index = if our_rank > op_rank; ahead
        elsif our_rank < op_rank;      behind
        else;                          tied
        end
        hp_total[index] += 1

        if table_cards.size < 5 # do not calculate potential for river
          possible_next_card = possible_op_cards - [op_card1, op_card2]
          possible_next_card.each do |new_card|
            new_table = table_cards + [Card.new(new_card)]
            our_best = hand_rank(new_table)

            op_hand_with_new_table = Hand.new(op_hand)
            op_hand_with_new_table.add_card(Card.new(new_card))
            op_best = HandEvaluator.rank_hand(op_hand_with_new_table)

            if our_best > op_best;    hp[index][ahead] += 1
            elsif our_best < op_best; hp[index][behind] += 1
            else;                     hp[index][tied] += 1
            end
          end
        end
      end

      ppot = npot = 0
      if table_cards.size < 5
        ppot = (hp[behind][ahead] + hp[behind][tied]/2.0 + hp[tied][ahead]/2.0) / (hp[behind].sum + hp[tied].sum/2.0)
        ppot = 0 if ppot.nan?
        npot = (hp[ahead][behind] + hp[tied][behind]/2.0 + hp[ahead][tied]/2.0) / (hp[ahead].sum + hp[tied].sum/2.0)
        npot = 0 if npot.nan?
      end

      hand_strength = (hp_total[ahead] + (hp_total[tied]/2.0)) / hp_total.sum

      return ppot.round(4), npot.round(4), hand_strength.round(4)
    end
  end

  class DummyPlayer < Player
    def bet(state)
      min_bet = state.min_bet

      choice = rand

      if min_bet > 0 && choice < 0.333 # FOLD
        fold
      elsif choice < 0.666 # CHECK
        get_from_stack(min_bet)
      else # RAISE
        raise_from(min_bet)
      end
    end
  end
end
