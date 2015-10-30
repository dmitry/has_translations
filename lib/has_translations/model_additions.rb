module HasTranslations
  module ModelAdditions
    extend ActiveSupport::Concern

    module ClassMethods
      def translated(locale)
        where(["#{self.has_translations_options[:translation_class].table_name}.locale = ?", locale.to_s]).joins(:translations)
      end

      def has_translations(*attrs)
        new_options = attrs.extract_options!
        options = {
          fallback: false,
          reader: true,
          writer: false,
          nil: '',
          autosave: new_options[:writer],
          translation_class: nil
        }.merge(new_options)

        translation_class_name = options[:translation_class].try(:name) || "#{self.model_name}Translation"
        options[:translation_class] ||= translation_class_name.constantize

        options.assert_valid_keys(
          [
            :fallback,
            :reader,
            :writer,
            :nil,
            :inverse_of,
            :autosave,
            :translation_class
          ]
        )

        belongs_to = self.model_name.to_s.demodulize.underscore.to_sym

        class_attribute :has_translations_options
        self.has_translations_options = options

        # associations, validations and scope definitions
        options[:translation_class].belongs_to(belongs_to)
        has_many(
          :translations,
          class_name: translation_class_name,
          dependent: :destroy,
          autosave: options[:autosave],
          inverse_of: options[:inverse_of]
        )
        options[:translation_class].validates(
          :locale,
          presence: true,
          uniqueness: {scope: :"#{belongs_to}_id"}
        )

        # Optionals delegated readers
        if options[:reader]
          attrs.each do |name|
            send :define_method, name do |*args|
              locale = args.first || I18n.locale
              translation = self.translation(locale)
              translation.try(name) || has_translations_options[:nil]
            end
          end
        end

        # Optionals delegated writers
        if options[:writer]
          attrs.each do |name|
            send :define_method, "#{name}_before_type_cast" do
              translation = self.translation(I18n.locale, false)
              translation.try(name)
            end

            send :define_method, "#{name}=" do |value|
              translation = find_or_build_translation(I18n.locale)
              translation.send(:"#{name}=", value)
            end
          end
        end
      end
    end

    def find_or_create_translation(locale)
      locale = locale.to_s
      (find_translation(locale) || self.has_translations_options[:translation_class].new).tap do |t|
        t.locale = locale
        t.send(:"#{self.class.model_name.to_s.demodulize.underscore.to_sym}_id=", self.id)
      end
    end

    def find_or_build_translation(locale)
      locale = locale.to_s
      (find_translation(locale) || self.translations.build).tap do |t|
        t.locale = locale
      end
    end

    def translation(locale, fallback=has_translations_options[:fallback])
      locale = locale.to_s
      find_translation(locale) || (fallback && !translations.blank? ? translations.detect { |t| t.locale == I18n.default_locale.to_s } || translations.first : nil)
    end

    def all_translations
      t = I18n.available_locales.map do |locale|
        [locale, find_or_create_translation(locale)]
      end
      ActiveSupport::OrderedHash[t]
    end

    def has_translation?(locale)
      find_translation(locale).present?
    end

    def find_translation(locale)
      locale = locale.to_s
      translations.detect { |t| t.locale == locale }
    end
  end
end
