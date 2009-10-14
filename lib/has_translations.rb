module HasTranslations
  module Model
    module ActiveRecord
      class << self
        def translation_model(klass)
          "#{klass.send(:model_name)}Translation"
        end

        def add_belongs_to_and_validations_translation_model(klass)
          translation_class = translation_model(klass).constantize
          belongs_to = klass.model_name.demodulize.singularize.underscore.to_sym
          translation_class.belongs_to belongs_to
          translation_class.validates_presence_of :locale, belongs_to
          translation_class.validates_uniqueness_of :locale, :scope => :"#{belongs_to}_id"
        end
      end

      module Translated
        def self.included(base)
          base.extend ActMethods
        end

        module ActMethods
          def translations(*attr_names)
            options = {:fallback => false}.merge(attr_names.extract_options!)

            #autoinclude
            #send(:default_scope).first[:find][:include] = :translations

            write_inheritable_attribute :has_translations_options, options
            class_inheritable_reader :has_translations_options

            has_many :translations, :class_name => HasTranslations::Model::ActiveRecord.translation_model(self), :dependent => :destroy

            send :define_method, :translation do |locale|
              locale = locale.to_s
              translations = self.translations.reload
              translations.detect { |t| t.locale == locale } || (has_translations_options[:fallback] && !translations.blank? ? translations.detect { |t| t.locale == I18n.default_locale.to_s } || translations.first : nil)
            end

            attr_names.each do |attr_name|
              send :define_method, attr_name do
                translation = self.translation(I18n.locale)
                translation.nil? ? '' : translation.send(attr_name)
              end
            end

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