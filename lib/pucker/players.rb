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
      state.hand_rank = hand_rank(state.table_cards)
      state.hand_strength = hand_strength(state.table_cards)
      amount = bet(state)
      state.set_decision(amount)
      @round_states << state
      amount
    end

    def bet(state)
      get_from_stack(state.min_bet)
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

    def hand_rank(table_cards)
      HandEvaluator.rank_hand(full_hand(table_cards))
    end

    def hand_strength(table_cards)
      ahead = behind = tied = 0
      our_rank = hand_rank(table_cards)

      # Consider all two card combinations of the remaining cards
      deck = (0..51).to_a
      known_cards = table_cards.map(&:get_index) + [hand.get_card_index(1), hand.get_card_index(2)]
      remaining_cards = deck - known_cards

      remaining_cards.combination(2) do |op_card1, op_card2|
        op_hand = Hand.new
        op_cards = table_cards + [Card.new(op_card1), Card.new(op_card2)]
        op_cards.each { |card| op_hand.add_card(card) }
        op_rank = HandEvaluator.rank_hand(op_hand)

        if our_rank > op_rank
          ahead += 1
        elsif our_rank < op_rank
          behind += 1
        else
          tied += 1
        end
      end

      return (ahead+(tied/2.0)) / (ahead+tied+behind)
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

    def stocastic_raise(min_bet, chance)
      random_choice = rand

      if random_choice < chance
        raise_from(min_bet)
      else
        get_from_stack(min_bet)
      end
    end

    def stocastic_check(min_bet, chance)
      random_choice = rand

      if random_choice < chance
        get_from_stack(min_bet)
      else
        raise_from(min_bet)
      end
    end

    def stocastic_fold(min_bet)
      random_choice = rand

      if random_choice < 0.9
        fold
      else
        get_from_stack(min_bet)
      end
    end

    def raise_from(min_bet)
      min_bet = BIG_BLIND if min_bet == 0

      if stack > (4 * min_bet)
        raise_factor = [2, 3, 4].sample
        get_from_stack(raise_factor * min_bet)
      else # ALLIN
        get_from_stack(stack)
      end
    end

    def store_state_reward(reward)
      @round_states.each { |state| state.reward = reward }
      @all_states += @round_states
      @round_states = []
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
