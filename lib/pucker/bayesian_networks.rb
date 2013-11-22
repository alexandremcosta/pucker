require 'sbn'

module Pucker
  class SimpleBn
    @@net = nil
    def self.get
      if @@net.nil?
        @@net = Sbn::Net.new("min_bet_hand_rank")
        min_bet = Sbn::Variable.new(@@net, :min_bet, [0.5, 0.5], [:zero, :over_zero])
        hand_rank = Sbn::Variable.new(@@net, :hand_rank, [0.3, 0.6, 0.1], [:low, :avg, :high])
        result = Sbn::Variable.new(@@net, :result, [0.6,0.4,0.8,0.2,0.9,0.1,0.1,0.9,0.6,0.4,0.9,0.1])
        min_bet.add_child(result)
        hand_rank.add_child(result)
      end
      return @@net
    end
  end

  class GoodBn
    @@net = nil
    def self.get
      if @@net.nil?
        @@net = Sbn::Net.new("scenario_hand_rank")
        min_bet = Sbn::Variable.new(@@net, :min_bet, [0.3, 0.4, 0.3], [:high, :low, :zero])
        table_rank = Sbn::Variable.new(@@net, :table_rank, [0.2, 0.8], [:high, :low])
        scenario = Sbn::Variable.new(@@net, :scenario, [0.05, 0.15, 0.8, 0.1, 0.2, 0.7, 0.05, 0.8, 0.15, 0.08, 0.9, 0.02, 0.85, 0.13, 0.02, 0.9, 0.1, 0.0], [:good, :medium, :bad])
        min_bet.add_child(scenario)
        table_rank.add_child(scenario)

        hand_rank = Sbn::Variable.new(@@net, :hand_rank, [0.1, 0.6, 0.3], [:high, :avg, :low])
        result = Sbn::Variable.new(@@net, :result, [1.0, 0.0, 0.8, 0.2, 0.6, 0.4, 0.999, 0.001, 0.4, 0.6, 0.1, 0.9, 0.99, 0.01, 0.3, 0.7, 0.0, 1.0])
        hand_rank.add_child(result)
        scenario.add_child(result)
      end
      return @@net
    end
  end

  class BestBn
    @@net = nil
    def self.get
      if @@net.nil?
        @@net = Sbn::Net.new("position_bet_hand_rank")
        min_bet = Sbn::Variable.new(@@net, :min_bet, [0.3, 0.4, 0.3], [:high, :low, :zero])
        position = Sbn::Variable.new(@@net, :position, [0.2, 0.8], [:high, :low])
        scenario = Sbn::Variable.new(@@net, :scenario, [0.1, 0.2, 0.7, 0.0, 0.1, 0.9, 0.3, 0.6, 0.1, 0.2, 0.5, 0.3, 0.95, 0.05, 0.0, 0.2, 0.6, 0.2], [:good, :medium, :bad])
        min_bet.add_child(scenario)
        position.add_child(scenario)

        hand_rank = Sbn::Variable.new(@@net, :hand_rank, [0.1, 0.6, 0.3], [:high, :avg, :low])
        result = Sbn::Variable.new(@@net, :result, [1.0, 0.0, 0.8, 0.2, 0.6, 0.4, 0.95, 0.05, 0.6, 0.4, 0.1, 0.9, 0.9, 0.1, 0.2, 0.8, 0.0, 1.0])
        hand_rank.add_child(result)
        scenario.add_child(result)
      end
      return @@net
    end
  end
end
