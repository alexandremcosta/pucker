# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
# 
# Responsible for dealing and shuffling a deck of cards

require 'java'
java_import 'table.Deck'

module Pucker
  class Dealer
    def initialize
      deck.shuffle
    end

    def deal
      deck.deal
    end

    def reset
      deck.reset
      deck.shuffle
    end

    private
    def deck
      @deck ||= Deck.new(0)
    end
  end
end
