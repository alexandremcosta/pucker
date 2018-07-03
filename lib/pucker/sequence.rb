# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Implements a sequence of numbers

module Pucker
  module Sequence
    @initial = 0
    def self.next
      @initial += 1
    end
  end
end
