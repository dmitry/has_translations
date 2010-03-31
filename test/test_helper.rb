require 'rubygems'
require 'test/unit'

gem 'activesupport', '~> 2.3'
gem 'activerecord', '~> 2.3'

require 'active_support'
require 'active_record'
require 'logger'

require 'has_translations'
require 'i18n_ext'

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