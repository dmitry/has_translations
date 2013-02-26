require 'rubygems'
require 'test/unit'

rails_version = "~> #{ENV['RAILS_VERSION'] || '3.2'}"

gem 'activerecord', rails_version
gem 'activesupport', rails_version

require 'active_record'
require 'logger'

require 'has_translations'

begin
  I18n.available_locales = :ru, :en, :es
rescue
  p "[WARNING]: This test should have the I18n.available_locales= method, which were included in versions ~> 0.3.0"
end

puts "Using Rails version: #{ActiveRecord::VERSION::STRING}"

ActiveRecord::Base.logger = Logger.new('test.log')
#ActiveRecord::Base.logger = nil
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
