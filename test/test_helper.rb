require 'rubygems'
require 'test/unit'

case ENV['RAILS_VERSION']
when '3.0' then
  gem 'activerecord', '~> 3.0.0'
  gem 'activesupport', '~> 3.0.0'
else
  gem 'activerecord', '~> 2.3.0'
  gem 'activesupport', '~> 2.3.0'
end

require 'active_record'
require 'logger'

require 'has_translations'

begin
  I18n.available_locales = :ru, :en, :es
rescue
  p "[WARNING]: This test should have the I18n.available_locales= method, which were included in versions ~> 0.3.0"
end

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
