# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Write logs to a file and to STDOUT

require 'logger'
require 'forwardable'

module Pucker
  class MultiLogger
    extend Forwardable
    def_delegators :@logger, :info, :error, :debug

    def initialize
      if ENV['test']
        log_file = File.open("./test.log", "a")
        @logger = Logger.new(MultiIO.new(log_file))
      else
        log_file = File.open("../pucker.log", "a")
        @logger = Logger.new(MultiIO.new(STDOUT, log_file))
      end
    end

    class MultiIO
      def initialize(*targets)
         @targets = targets
      end

      def write(*args)
        @targets.each {|t| t.write(*args)}
      end

      def close
        @targets.each(&:close)
      end
    end
  end
end
