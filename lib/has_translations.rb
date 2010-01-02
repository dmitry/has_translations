module HasTranslations
  def self.translation_model(klass)
    "#{klass.send(:model_name)}Translation"
  end

  def self.add_belongs_to_and_validations_translation_model(klass)
    translation_class = translation_model(klass).constantize
    belongs_to = klass.model_name.demodulize.singularize.underscore.to_sym
    translation_class.belongs_to belongs_to
    translation_class.validates_presence_of :locale, belongs_to
    translation_class.validates_uniqueness_of :locale, :scope => :"#{belongs_to}_id"
  end
end

class ActiveRecord::Base
  def self.translations(*attrs)
    options = {:fallback => false}.merge(attrs.extract_options!)

    write_inheritable_attribute :has_translations_options, options
    class_inheritable_reader :has_translations_options

    has_many :translations, :class_name => HasTranslations.translation_model(self), :dependent => :destroy

    send :define_method, :translation do |locale|
      locale = locale.to_s
      translations = self.translations.reload
      translations.detect { |t| t.locale == locale } || (has_translations_options[:fallback] && !translations.blank? ? translations.detect { |t| t.locale == I18n.default_locale.to_s } || translations.first : nil)
    end

    attrs.each do |name|
      send :define_method, name do
        translation = self.translation(I18n.locale)
        translation.nil? ? '' : translation.send(name)
      end
    end

    HasTranslations.add_belongs_to_and_validations_translation_model(self)

    include HasTranslations
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