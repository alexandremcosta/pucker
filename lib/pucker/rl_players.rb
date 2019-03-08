module Pucker
  class RlPlayer < NnPlayer
    private
    def predict_decisions(state)
      if state.flop? || state.turn?
        future_check, future_raise = predict_future(state)

        predicted_check = predict_check(state)
        check_val = (predicted_check+future_check)/2.0
        LOG.info("Predicted check: #{predicted_check}")
        LOG.info("Future check: #{future_check}")
        LOG.info("Check val: #{check_val}")

        predicted_raise = predict_raise(state)
        raise_val = (predicted_raise+future_raise)/2.0
        LOG.info("Predicted raise: #{predicted_raise}")
        LOG.info("Future raise: #{future_raise}")
        LOG.info("Raise val: #{raise_val}")


        { raise: raise_val,
          check: check_val,
          fold: predict_fold(state) }
      else
        super(state)
      end
    end

    def predict_future(state)
      states = enumerate_future_states(state)

      states.each do |s|
        reset_decision(s)
        s.decision_check = s.min_bet
      end

      params = states.map(&:predict_params)
      prediction = JSON.parse(request(params))
      average_check = prediction.sum / prediction.size

      states.each do |s|
        reset_decision(s)
        s.decision_raise = amount_to_raise(s.min_bet)
      end

      params = states.map(&:predict_params)
      prediction = JSON.parse(request(params))
      average_raise = prediction.sum / prediction.size

      return average_check, average_raise
    end

    def enumerate_future_states(state)
      table_cards = state.table_cards
      deck = (0..51).to_a
      known_cards = table_cards.map(&:get_index) + [hand.get_card_index(1), hand.get_card_index(2)]
      possible_next_card = deck - known_cards

      possible_next_card.map do |card_index|
        new_state = State.new(state.attributes)
        table_cards = state.table_cards + [Card.new(card_index)]
        new_state.set_cards(table_cards, hand)
        set_hand_status(new_state)

        new_state
      end
    end

    def endpoint; 'pred_700' end
  end
end

