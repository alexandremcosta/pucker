# run with NOLOG=true jruby -J-Xmn1024m -J-Xms4096m -J-Xmx4096m -J-server
require_relative '../lib/pucker'
g = Pucker::Game.new

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

10.times do |n|
  10.times { g.play }
  g.players.persist_states

  ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  elapsed = ending - starting
  print "#{n+1}/100 in #{(elapsed/60.0).round(1)} minutes\r"
  $stdout.flush
end

ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting
puts "\n10000 games run in #{elapsed.to_i} seconds OR #{(elapsed/60.0).to_i} minutes OR #{(elapsed/(60*60.0)).round(2)} hours"
