require_relative 'players'
require 'manticore'

module Pucker
  class NnPlayer < Player
    def bet(state)
      decision = {
        fold: predict_fold(state),
        check: predict_check(state),
        raise: predict_raise(state) }

      decision = decision.key(decision.values.max)
      decision = :check if decision == :fold && state.min_bet == 0

      case decision
      when :fold
        fold
      when :check
        get_from_stack(state.min_bet)
      when :raise
        raise_from(state.min_bet)
      end
    end

    private
    def predict_fold(state)
      reset_decision(state)
      state.decision_fold = 1
      predict(state)
    end

    def predict_check(state)
      reset_decision(state)
      state.decision_check = state.min_bet
      predict(state)
    end

    def predict_raise(state)
      reset_decision(state)
      state.decision_raise = state.min_bet * 4
      predict(state)
    end

    def reset_decision(state)
      state.decision_fold = 0
      state.decision_check = 0
      state.decision_raise = 0
    end

    def predict(state)
      prediction = request(state.predict_params)
      prediction.to_i
    end

    def request(params)
      Manticore.post("http://127.0.0.1:8080/predict", params: params).body
    end
  end
end

