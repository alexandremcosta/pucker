# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Main module of the framework, responsible for general configurations.

$CLASSPATH << File.expand_path('../pucker', __FILE__)
require_relative 'pucker/game'
require_relative 'pucker/statistic'

module Pucker
  NUM_PLAYERS = 5
  STACK = 2000
  BIG_BLIND = 20
  SMALL_BLIND = 10
  LOG = MultiLogger.new
  STATISTIC = Statistic.new
end
