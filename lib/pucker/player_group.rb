require_relative 'player'

module Pucker
  class PlayerGroup < Array
    def set_hands(dealer)
      self.each do |player|
        player.set_hand(dealer.deal, dealer.deal)
      end
    end

    def create_players(num_of_players)
      num_of_players.times do self << player_source.call end
    end

    def player_source
      @player_source ||= Player.public_method(:new)
    end

    def rotate_positions
      self.rotate!
    end
  end
end
