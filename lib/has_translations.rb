class ActiveRecord::Base
  def self.translations(*attrs)
    options = {:fallback => false, :translation_validations => true}.merge(attrs.extract_options!)
    translation_class_name = "#{self.model_name}Translation"

    write_inheritable_attribute :has_translations_options, options
    class_inheritable_reader :has_translations_options

    has_many :translations, :class_name => translation_class_name, :dependent => :destroy

    def translation(locale)
      locale = locale.to_s
      translations.detect { |t| t.locale == locale } || (has_translations_options[:fallback] && !translations.blank? ? translations.detect { |t| t.locale == I18n.default_locale.to_s } || translations.first : nil)
    end

    attrs.each do |name|
      send :define_method, name do
        translation = self.translation(I18n.locale)
        translation.nil? ? '' : translation.send(name)
      end
    end

    if options[:translation_validations]
      translation_class = translation_class_name.constantize
      belongs_to = self.model_name.demodulize.singularize.underscore.to_sym # TODO simplify?
      translation_class.belongs_to belongs_to
      translation_class.validates_presence_of :locale, belongs_to
      translation_class.validates_uniqueness_of :locale, :scope => :"#{belongs_to}_id"
    end
  end
end

# TODO remove in i18n version > 0.2 (rails 3.0)
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