# Author: Alexandre Marangoni Costa
# Email: alexandremcost at gmail dot com
#
# Outputs statistics of the game

require 'gruff'
require 'fileutils'

module Pucker
  class Statistic
    attr_reader :losses, :bankroll

    def initialize
      @losses = {}
      @bankroll = {}
    end

    def print_all
      print_losses
    end

    def increase_losses(player)
      @losses[player.id] ||= 0
      @losses[player.id] += 1
    end

    def print_losses
      puts "Number of rebuys: player - number"
      @losses.each do |p, n|
        puts "#{p} - #{n}"
      end
    end

    def add_bankroll(player)
      losses = @losses[player.id] || 0
      @bankroll[player.id] ||= []
      @bankroll[player.id] << player.stack - (losses*Pucker::STACK)
    end

    def persist_bankroll_mbb(phase, round)
      dirname = "results/phase#{phase}"
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      filename = "#{dirname}/round#{round}"

      file_mbb(filename)
      plot_bankroll(filename, false)
    end

    def file_mbb(filename='mbb')
      phase = filename.split('/')[1] || ''
      round = filename.split('/')[2] || ''
      title = round.empty? ? '' : "#{phase.capitalize} #{round}\n"

      filename = "#{filename}.txt"

      output = "#{phase.capitalize} #{round}\nMili big blinds won per game:\nplayer:\tnumber\n"
      mbb_per_game.each do |p, n|
        output += "#{p}:\t#{n}\n"
      end

      File.open(filename, 'w') { |file| file.write(output) }
    end

    def plot_bankroll(filename='bankroll', delete=true)
      phase = filename.split('/')[1] || ''
      round = filename.split('/')[2] || ''
      title = round.empty? ? '' : "#{phase.capitalize} #{round}:"

      filename = "#{filename}.png"

      g = Gruff::Line.new
      g.theme = chart_theme
      g.line_width = 2
      g.reference_lines[:baseline]  = { value: Pucker::STACK, color: '#999999' }
      g.title = "#{title} stack over time"
      g.hide_dots = true

      bankroll_sorted.each do |player, array|
        g.data(player, [Pucker::STACK] + array)
      end

      n_labels = 5
      g.labels = {}
      n_labels.times do |n|
        label = number_of_games * n / (n_labels - 1)
        g.labels[label] = label
      end

      g.write(filename)

      system("xdg-open #{filename}")
      File.delete(filename) if delete
    end

    def print_mbb
      puts "Mili big blinds won per game:\nplayer:\tnumber"
      mbb_per_game.each do |p, n|
        puts "#{p}:\t#{n}"
      end
    end

    private
    # mili big blinds per game
    def mbb_per_game
      mbb_per_game = {}
      bankroll_sorted.each do |player, array|
        chips_won = array.last - Pucker::STACK
        mbb_per_game[player] = (chips_won * 1000) / (Pucker::BIG_BLIND * number_of_games)
      end

      return mbb_per_game
    end

    def chart_theme
      theme = Gruff::Themes::THIRTYSEVEN_SIGNALS
      theme[:colors] = [
        '#cf5910',  # orange
        '#336699',  # blue
        '#339933',  # green
        '#ff0000',  # red
        '#cc99cc',  # purple
        '#FFF804',  # yellow
        'black'
      ]
      return theme
    end

    def bankroll_sorted
      @bankroll.sort.to_h
    end

    def number_of_games
      @bankroll.first.last.size rescue 0
    end
  end
end
