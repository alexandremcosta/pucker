require_relative 'player'

module Pucker
  class PlayerGroup < Array
    def create_players(count)
      count.times { self << player_source.call }
    end

    def player_source
      @player_source ||= Player.public_method(:new)
    end
  end
end
