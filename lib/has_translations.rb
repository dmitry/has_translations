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
  # For more information please read API. Feel free to write me an email to:
  # dmitry.polushkin@gmail.com.
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
    options = {
      :fallback => false,
      :reader => true,
      :writer => false,
      :nil => ''
    }.merge(attrs.extract_options!)

    options.assert_valid_keys([:fallback, :reader, :writer, :nil])

    translation_class_name = "#{self.model_name}Translation"
    translation_class = translation_class_name.constantize
    belongs_to = self.model_name.demodulize.singularize.underscore.to_sym

    write_inheritable_attribute :has_translations_options, options
    class_inheritable_reader :has_translations_options

    send :define_method, :find_or_build_translation do |*args|
      locale = args.first.to_s
      build = args.second.present?
      find_translation(locale) || (build ? self.translations.build(:locale => locale) : self.translations.new(:locale => locale))
    end

    def translation(locale, fallback=has_translations_options[:fallback])
      locale = locale.to_s
      find_translation(locale) || (fallback && !translations.blank? ? translations.detect { |t| t.locale == I18n.default_locale.to_s } || translations.first : nil)
    end

    def all_translations
      t = I18n.available_locales.map do |locale|
        [locale, find_or_build_translation(locale)]
      end
      ActiveSupport::OrderedHash[t]
    end

    def has_translation?(locale)
      find_translation(locale).present?
    end

    if options[:reader]
      attrs.each do |name|
        send :define_method, name do
          translation = self.translation(I18n.locale)
          translation.nil? ? has_translations_options[:nil] : translation.send(name)
        end
      end
    end

    if options[:writer]
      attrs.each do |name|
        send :define_method, "#{name}=" do |value|
          translation = find_or_build_translation(I18n.locale, true)
          translation.send(:"#{name}=", value)
        end
      end
    end

    has_many :translations, :class_name => translation_class_name, :dependent => :destroy
    
    translation_class.belongs_to belongs_to
    translation_class.validates_presence_of :locale
    translation_class.validates_uniqueness_of :locale, :scope => :"#{belongs_to}_id"

    # Workaround to support Rails 2
    scope_method = if ActiveRecord::VERSION::MAJOR < 3 then :named_scope else :scope end

    send scope_method, :translated, lambda { |locale| {:conditions => ["#{translation_class.table_name}.locale = ?", locale.to_s], :joins => :translations} }

    private

    def find_translation(locale)
      locale = locale.to_s
      translations.detect { |t| t.locale == locale }
    end
  end
end
