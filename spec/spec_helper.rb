ENV['test'] = 'true'

require 'pucker'

RSpec.configure do |config|
  config.filter_run wip: true
  config.run_all_when_everything_filtered = true
end
