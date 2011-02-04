require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the has_translations plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the has_translations plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'HasTranslations'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "has_translations"
    gemspec.summary = "Create translations for your ActiveRecord models."
    gemspec.description = "Create translations for your ActiveRecord models. Uses delegate pattern. Fully tested and used in a several production sites."
    gemspec.email = "dmitry.polushkin@gmail.com"
    gemspec.homepage = "http://github.com/dmitry/has_translations"
    gemspec.authors = ["Dmitry Polushkin"]
    gemspec.version = '0.3.2'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
