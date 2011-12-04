class ActiveRecord::Base
  # Provides ability to add the translations for the model using delegate pattern.
  # Uses has_many association to the ModelNameTranslation.
  #
  # For example you have model Article with attributes title and text.
  # You want that attributes title and text to be translated.
  # For this reason you need to generate new model ArticleTranslation.
  # In migration you need to add:
  #
  #   create_table :article_translations do |t|
  #     t.references :article, :null => false
  #     t.string :locale, :length => 2, :null => false
  #     t.string :name, :null => false
  #   end
  #
  #   add_index :articles, [:article_id, :locale], :unique => true, :name => 'unique_locale_for_article_id'
  #
  # And in the Article model:
  #
  #   translations :title, :text
  #
  # This will adds:
  #
  # * named_scope (translated) and has_many association to the Article model
  # * locale presence validation to the ArticleTranslation model.
  #
  # Notice: if you want to have validates_presence_of :article, you should use :inverse_of.
  # Support this by yourself. Better is always to use artile.translations.build() method.
  #
  # ===
  #
  # You also can pass attributes and options to the translations class method:
  #
  #   translations :title, :text, :fallback => true, :writer => true, :nil => nil
  #
  # ===
  #
  # Configuration options:
  #
  # * <tt>:fallback</tt> - if translation for the current locale not found.
  #   By default false. Set to true if you want to use reader fallback.
  #   Uses algorithm of fallback:
  #   0) current translation (using I18n.locale);
  #   1) default locale (using I18n.default_locale);
  #   2) first from translations association;
  #   3) :nil value (see <tt>:nil</tt> configuration option)
  # * <tt>:reader</tt> - add reader attributes to the model and delegate them
  #   to the translation model columns. Add's fallback if it is set to true.
  # * <tt>:writer</tt> - add writer attributes to the model and assign them
  #   to the translation model attributes.
  # * <tt>:nil</tt> - when reader cant find string, it returns by default an
  #   empty string. If you want to change this setting for example to nil,
  #   add :nil => nil
  #
  # ===
  #
  # When you are using <tt>:writer</tt> option, you can create translations using
  # update_attributes method. For example:
  #
  #   Article.create!
  #   Article.update_attributes(:title => 'title', :text => 'text')
  #
  # ===
  #
  # <tt>translated</tt> named_scope is useful when you want to find only those
  # records that are translated to a specific locale.
  # For example if you want to find all Articles that is translated to an english
  # language, you can write: Article.translated(:en)
  #
  # <tt>has_translation?(locale)</tt> method, that returns true if object's model
  # have a translation for a specified locale
  #
  # <tt>translation(locale)</tt> method finds translation with specified locale.
  #
  # <tt>all_translations</tt> method that returns all possible translations in
  # ordered hash (useful when creating forms with nested attributes).
  def self.translations(*attrs)
    new_options = attrs.extract_options!
    options = {
      :fallback => false,
      :reader => true,
      :writer => false,
      :nil => '',
      :autosave => new_options[:writer]
    }.merge(new_options)

    options.assert_valid_keys([:fallback, :reader, :writer, :nil, :autosave])

    translation_class_name = "#{self.model_name}Translation"
    translation_class = translation_class_name.constantize
    belongs_to = self.model_name.demodulize.underscore.to_sym

    if ActiveRecord::VERSION::MAJOR < 3
      write_inheritable_attribute :has_translations_options, options
      class_inheritable_reader :has_translations_options

      scope_method = :named_scope
    else
      class_attribute :has_translations_options
      self.has_translations_options = options

      scope_method = :scope
    end

    # associations, validations and scope definitions
    has_many :translations, :class_name => translation_class_name, :dependent => :destroy, :autosave => options[:autosave]
    translation_class.belongs_to belongs_to
    translation_class.validates_presence_of :locale
    translation_class.validates_uniqueness_of :locale, :scope => :"#{belongs_to}_id"
    send scope_method, :translated, lambda { |locale| {:conditions => ["#{translation_class.table_name}.locale = ?", locale.to_s], :joins => :translations} }

    public

    define_method :find_or_create_translation do |locale|
      locale = locale.to_s
      (find_translation(locale) || translation_class.new).tap do |t|
        t.locale = locale
        t.send(:"#{belongs_to}_id=", self.id)
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

    if options[:reader]
      attrs.each do |name|
        send :define_method, name do |*args|
          locale = args.first || I18n.locale
          translation = self.translation(locale)
          translation.try(name) || has_translations_options[:nil]
        end
      end
    end

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

    private

    def find_translation(locale)
      locale = locale.to_s
      translations.detect { |t| t.locale == locale }
    end
  end
end
