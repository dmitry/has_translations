require 'rails/generators/active_record'

class TranslationForGenerator < ActiveRecord::Generators::Base

  desc "Description:\n  Generate translation for ActiveRecord model"
  source_root File.expand_path("../templates", __FILE__)

  argument :attributes, :type => :array, :default => [], :banner => "field_1:text field_2:string field_3:another_type"

  def check_attributes
    puts table_name
    if attributes.blank?
      puts "Define at least one translated attribute"
      exit
    end
  end

  def create_model
    template 'model.rb.erb', File.join('app/models', class_path, "#{file_name}.rb")
  end

  def create_migration
    migration_template 'migration.rb.erb', "db/migrate/create_#{table_name}"
  end

  private

  def name_with_translation
    "#{name_without_translation.underscore}_translation"
  end

  alias_method_chain :name, :translation

  def old_active_record?
    (ActiveRecord::VERSION::MAJOR < 3) || (ActiveRecord::VERSION::MAJOR == 3 && ActiveRecord::VERSION::MINOR == 0)
  end

  def foreign_key_name
    "#{name_without_translation.underscore}_id"
  end

end
