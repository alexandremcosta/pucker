$CLASSPATH << File.expand_path('../pucker', __FILE__)
require_relative 'pucker/game'

module Pucker
  NUM_PLAYERS = 5
  STACK = 2000
  BIG_BLIND = 20
  SMALL_BLIND = 10
end
