#!/usr/bin/ruby

# for high performance run with
# NOLOG=true jruby -J-Xmn1024m -J-Xms4096m -J-Xmx4096m -J-server

require_relative '../lib/pucker'

# TODO: script parameters
phase = 3
round = 3
# Pucker::State.delete_all

g = Pucker::Game.new
puts('Running')

def get_time; Process.clock_gettime(Process::CLOCK_MONOTONIC) end

start_at = get_time
n_games = 0

10.times do |n|
  10.times do |m|
    30.times { g.play; n_games += 1 }
    # g.play; n_games += 1

    progress = 10*n + m + 1

    elapsed = get_time - start_at
    elapsed_min = (elapsed/60.0)
    remaining_min = elapsed_min*100/progress - elapsed_min
    print "#{progress.round(1)}% in #{elapsed_min.round(1)} minutes. Remaining #{remaining_min.round(1)} minutes, #{(remaining_min/60.0).round(2)} hours.\r"
    $stdout.flush
  end

  g.players.persist_states
end

elapsed = get_time - start_at
puts "\n#{n_games} games run in #{elapsed.to_i} seconds OR #{(elapsed/60.0).to_i} minutes OR #{(elapsed/(60*60.0)).round(1)} hours"

Pucker::STATISTIC.persist_bankroll_mbb(phase, round)
