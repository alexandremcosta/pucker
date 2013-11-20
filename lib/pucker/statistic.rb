module Pucker
  class Statistic
    attr_reader :losses

    def initialize
      @losses = {}
    end

    def increase_losses(player)
      @losses[player] ||= 0
      @losses[player] += 1
    end

    def get_losses(player)
      @losses[player] || 0
    end
  end
end
