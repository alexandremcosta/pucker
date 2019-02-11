require_relative 'players'
require 'manticore'

module Pucker
  class NnPlayer < Player
    def bet(state)
      decisions = {
        raise: predict_raise(state),
        check: predict_check(state),
        fold: predict_fold(state)
      }

      decision = decisions.key(decisions.values.max)
      decision = :fold if decisions.values.all? { |val| val < 0 }
      decision = :check if decision == :fold && state.min_bet == 0

      if decision == :raise && state.min_bet > 0
        raise_amount = amount_to_raise(state.min_bet)
        net_win = decisions[:raise] - raise_amount
        decision = :check if net_win < raise_amount
      end

      case decision
      when :check
        stocastic_check(state.min_bet)
      when :raise
        stocastic_raise(state.min_bet)
      else
        stocastic_fold(state.min_bet)
      end
    end

    private
    def predict_fold(state)
      predict(state) do |s|
        s.decision_fold = 1
      end
    end

    def predict_check(state)
      predict(state) do |s|
        s.decision_check = state.min_bet
        s.decision_check = 1 if state.min_bet == 0
      end
    end

    def predict_raise(state)
      predict(state) do |s|
        s.decision_raise = amount_to_raise(s.min_bet)
      end
    end

    def predict(state)
      reset_decision(state)
      yield(state)
      prediction = request(state.predict_params)

      return prediction.to_i
    end

    def reset_decision(state)
      state.decision_fold = 0
      state.decision_check = 0
      state.decision_raise = 0
    end

    def amount_to_raise(min_bet)
      amount = (min_bet == 0) ? BIG_BLIND : min_bet
      return 2 * amount
    end

    def request(params)
      Manticore.post("http://127.0.0.1:#{port}/#{endpoint}", params: params).body
    end

    def endpoint
      raise 'this method should be overriden and return an endpoint'
    end

    def port; 8081 end
  end

  class NnPlayer1000 < NnPlayer
    private
    def endpoint; 'pred_1000' end
  end

  class NnPlayer700 < NnPlayer
    private
    def endpoint; 'pred_700' end
  end

  class NnPlayer350 < NnPlayer
    private
    def endpoint; 'pred_350' end
  end

  class NnPlayer175 < NnPlayer
    private
    def endpoint; 'pred_175' end
  end
end

