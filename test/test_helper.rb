require 'rubygems'
require 'test/unit'

gem 'activerecord', '~> 2.3'
gem 'i18n', '~> 0.4'

require 'active_record'
require 'logger'

require 'has_translations'

#ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger = nil
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Migration.verbose = false
  load "schema.rb"
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end