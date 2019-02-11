# run with NOLOG=true jruby -J-Xmn1024m -J-Xms4096m -J-Xmx4096m -J-server
require_relative '../lib/pucker'
g = Pucker::Game.new

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

200.times do |n|
  200.times { g.play }
  g.players.persist_states

  ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  elapsed = ending - starting

  progress = ((n+1)/2.0)
  elapsed_min = (elapsed/60.0)
  remaining_min = elapsed_min*100/progress - elapsed_min
  print "#{progress.round(1)}% in #{elapsed_min.round(1)} minutes. Remaining #{remaining_min.round(1)} minutes, #{(remaining_min/60.0).round(2)} hours.\r"
  $stdout.flush
end

ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting
puts "\n40000 games run in #{elapsed.to_i} seconds OR #{(elapsed/60.0).to_i} minutes OR #{(elapsed/(60*60.0)).round(2)} hours"
