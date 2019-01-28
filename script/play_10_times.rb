require 'lib/pucker'

g = Pucker::Game.new
10.times { g.play }
Pucker::STATISTIC.print_losses
Pucker::STATISTIC.print_high_stack
Pucker::STATISTIC.print_table_king
