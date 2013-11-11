require 'logger'
require 'forwardable'

class MultiLogger
  extend Forwardable
  def_delegators :@logger, :info, :error

  def initialize
    log_file = File.open("../pucker.log", "a")
    @logger = Logger.new MultiIO.new(STDOUT, log_file)
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
