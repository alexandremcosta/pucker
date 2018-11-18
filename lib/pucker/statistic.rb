# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Outputs statistics of the game

module Pucker
  class Statistic
    attr_reader :losses, :high_stack

    def initialize
      @losses = {}
      @high_stack = {}
      @table_king = {}
    end

    def print_all
      print_losses
      print_high_stack
      print_table_king
    end

    def increase_losses(player)
      @losses[player] ||= 0
      @losses[player] += 1
    end

    def get_losses(player)
      @losses[player] || 0
    end

    def print_losses
      puts "Number of rebuys: player - number"
      @losses.each do |p, n|
        puts "#{p.id} - #{n}"
      end
    end

    def increase_high_stack(player)
      @high_stack[player] ||= 0
      @high_stack[player] += 1
    end

    def get_high_stack(player)
      @high_stack[player] || 0
    end

    def print_high_stack
      puts "Number of games with stack over 2000: player - number"
      @high_stack.each do |p, n|
        puts "#{p.id} - #{n}"
      end
    end

    def increase_table_king(player)
      @table_king[player] ||= 0
      @table_king[player] += 1
    end

    def get_table_king(player)
      @table_king[player] || 0
    end

    def print_table_king
      puts "Number of games being table king: player - number"
      @table_king.each do |p, n|
        puts "#{p.id} - #{n}"
      end
    end
  end
end
