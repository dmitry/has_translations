module HasTranslations
  module Model
    module ActiveRecord
      class << self
        def define_readers(klass, attr_names)
          klass.send :define_method, :translation do |locale|
            locale = locale.to_s
            translation = self.send(:translations).detect { |t| t.locale == locale }
          end
          
          attr_names.each do |attr_name|
            klass.send :define_method, attr_name do
              translation = self.translation(I18n.locale)
              translation.blank? ? '' : translation.send(attr_name)
            end
          end
        end

        def translation_model(klass)
          "#{klass.send(:model_name)}Translation"
        end

        def add_belongs_to_and_validations_translation_model(klass)
          translation = translation_model(klass).constantize
          belongs_to = klass.model_name.demodulize.singularize.underscore.to_sym
          translation.belongs_to belongs_to
          translation.validates_presence_of :locale, belongs_to
        end
      end

      module Translated
        def self.included(base)
          base.extend ActMethods
        end

        module ActMethods
          def translations(*attr_names)
            #options = attr_names.extract_options!

            #send(:default_scope).first[:find][:include] = :"#{self.send(:model_name).singular}_translations"

            #unless included_modules.include? InstanceMethods
            has_many :translations, :class_name => HasTranslations::Model::ActiveRecord.translation_model(self), :dependent => :destroy
            #end

            HasTranslations::Model::ActiveRecord.define_readers(self, attr_names)
            HasTranslations::Model::ActiveRecord.add_belongs_to_and_validations_translation_model(self)
          end
        end
      end
    end
  end
end

module ::I18n
  class << self
    def available_locales
      if @available_locales
        @available_locales
      else
        backend.available_locales
      end
    end

    def available_locales=(args)
      @available_locales = *args
    end
  end
end

ActiveRecord::Base.send :include, HasTranslations::Model::ActiveRecord::Translated