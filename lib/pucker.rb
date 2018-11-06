# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Main module of the framework, responsible for general configurations.

# enable debugging
require 'ruby-debug'

# connect to database
require 'active_record'
require 'activerecord-jdbcsqlite3-adapter'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/test'
)

# setup
$CLASSPATH << File.expand_path('../pucker', __FILE__)
require_relative 'pucker/initializers'
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
