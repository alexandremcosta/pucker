require 'java'
$CLASSPATH << File.expand_path('../', __FILE__)
java_import 'table.Deck'

module Pucker

  class Dealer
    def initialize
      @deck = Deck.new(0)
      @deck.shuffle
    end

    def deal
      @deck.deal
    end
  end
end
