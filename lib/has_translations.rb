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

require "has_translations/model_additions"
require "has_translations/railtie" if defined? Rails

module HasTranslations

end
