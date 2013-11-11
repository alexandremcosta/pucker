$CLASSPATH << File.expand_path('../pucker', __FILE__)
require_relative 'pucker/game'
require_relative 'pucker/multi_logger'

module Pucker
  NUM_PLAYERS = 5
  STACK = 2000
  BIG_BLIND = 20
  SMALL_BLIND = 10
  LOG = MultiLogger.new
end
