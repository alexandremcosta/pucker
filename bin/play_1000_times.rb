require 'lib/pucker'

g = Pucker::Game.new
1000.times { g.play }
Pucker::STATISTIC.print_losses
Pucker::STATISTIC.print_high_stack
Pucker::STATISTIC.print_table_king
