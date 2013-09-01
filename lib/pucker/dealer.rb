require 'java'
$CLASSPATH << File.expand_path('../', __FILE__)
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
