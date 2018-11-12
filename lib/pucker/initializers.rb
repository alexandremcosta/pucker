# enable debugging
require 'ruby-debug'

# connect to database
require 'active_record'
require 'activerecord-jdbcsqlite3-adapter'

def db_configuration
  db_configuration_file = File.join(File.expand_path('../..', __FILE__), '..', 'db', 'config.yml')
  YAML.load(File.read(db_configuration_file))
end

# fix backwards arel compatibility
ActiveRecord::Base.establish_connection(db_configuration["development"])
module Arel
  module Visitors
    class DepthFirst < Arel::Visitors::Visitor
      alias :visit_Integer :terminal
    end

    class Dot < Arel::Visitors::Visitor
      alias :visit_Integer :visit_String
    end

    class ToSql < Arel::Visitors::Visitor
      alias :visit_Integer :literal
    end
  end
end
