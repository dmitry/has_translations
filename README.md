HasTranslations v0.3.pre
====================

This simple plugin creates translations for your model.
Uses delegation pattern: http://en.wikipedia.org/wiki/Delegation_pattern

*NOTE:* this is prerelease. In several weeks I will cleanup everything and create a gem.
Usage of this version on your own risk. Use 0.2 tag instead, if you want stable one.

Example
=======

For example you have Article model and you want to have title and text to be translated.

Create model named ArticleTranslation (Rule: [CamelCaseModelName]Translation)

Migration should have `locale` as a string with two letters and `belongs_to associative id`, like:

    class CreateArticleTranslations < ActiveRecord::Migration
      def self.up
        create_table :article_translations do |t|
          t.integer :article_id, :null => false
          t.string :locale, :null => false, :limit => 2
          t.string :title, :null => false
          t.text :text, :null => false
        end

        add_index :article_translations, [:article_id, :locale], :unique => true
      end

      def self.down
        drop_table :article_translations
      end
    end

Add to article model `translations :value1, :value2`:

    class Article < ActiveRecord::Base
      translations :title, :text
    end

And that's it. Now you can add your translations using:

    article = Article.create

    article.translations.create(:locale => 'en', :title => 'title', :text => 'text') # or ArticleTranslation.create(:article => article, :locale => 'en', :title => 'title', :text => 'text')
    article.translations.create(:locale => 'ru', :title => 'заголовок', :text => 'текст')
    article.reload # reload cached translations association array
    I18n.locale = :en
    article.text # text
    I18n.locale = :ru
    article.title # заголовок

You can use text filtering plugins, like acts_as_sanitiled and validations, and anything else that is available to the ActiveRecord:

    class ArticleTranslation < ActiveRecord::Base
      acts_as_sanitiled :title, :text

      validates_presence_of :title, :text
      validates_length_of :title, :maximum => 100
    end

Options:

* :fallback => true [default: false] - fallback 1) default locale; 2) first from translations;
* :reader => false [default: true] - add reader to the model object
* :writer => true [default: false] - add writer to the model object
* :nil => nil [default: ''] - if no model found by default returns empty string, you can set it for example to `nil` (no `lambda` supported)

It's better to use translations with `accepts_nested_attributes_for`:

    accepts_nested_attributes_for :translations

To create a form for this you can use `all_translations` method. It's have all
the locales that you have added using the `I18n.available_locales=` method.
If translation for one of the locale isn't exists, it will build it with :locale.
So an example which I used in the production (using `formtastic` gem):

    <% semantic_form_for [:admin, @article] do |f| %>
      <%= f.error_messages %>

      <% f.inputs :name => "Basic" do %>
        <% object.all_translations.values.each do |translation| %>
          <% f.semantic_fields_for :translations, translation do |ft| %>
            <%= ft.input :title, :label => "Title #{ft.object.locale.to_s.upcase}" %>
            <%= ft.input :text, :label => "Text #{ft.object.locale.to_s.upcase}" %>
            <%= ft.input :locale, :as => :hidden %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>

Sometimes you have validations in the translation model, and if you want to skip
the translations that you don't want to add to the database, you can use
`:reject_if` option, which is available for the `accepts_nested_attributes_for`:

    accepts_nested_attributes_for :translations, :reject_if => lambda { |attrs| attrs['title'].blank? && attrs['text'].blank? }

Added named_scope `translated(locale)`. With that named_scope you can find only
those models that is translated only to specific locale. For example if you will
have 2 models, one is translated to english and the second one isn't, then it
`Article.translated(:en)` will find only first one.

PS
==

Plugin also have small monkeypatch for the I18n gem. Using it you can define your own available_locales through:

    I18n.available_locales = :en, :ru, :de

And get those values through:

    I18n.available_locales

This is done because of some plugins have own (for example ActiveScaffold has "ru, es, hu" in-box) locales, and this can be a problem for the all_translation method to build an array. To override this, you can place I18n.available_locales= to your environment.rb file, e.g.:

    I18n.available_locales = :en, :ru, :ee

TODO
====

* active record 3 (rails 3) support
* add installation description to readme
* model and migration generators
* caching
* write more examples: fallback feature
* write blog post about comparison and benefits of this plugin between another translation model plugins


Alternatives
============

I know three of them:

* [puret](http://github.com/jo/puret) - special for Rails 3 and almost the same as this project.
* [globalite2](http://github.com/joshmh/globalize2) - a lot of magic.
* [model_translations](http://github.com/janne/model_translations) - almost the same as this project, but more with more code in lib.
* [translatable_columns](http://github.com/iain/translatable_columns) - different approach: every column have own postfix "_#{locale}" in the same table (sometimes it could be fine).


Used in
=======

* [noch.es](http://noch.es/)
* [domnatenerife.ru](http://www.domnatenerife.ru/) ([etenproperty.com](http://www.etenproperty.com) / [etenproperty.de](http://www.etenproperty.de) / [eten.es](http://www.eten.es))
* [sem.ee](http://sem.ee/) ([sem.ee/ru](http://sem.ee/ru/) / [sem.ee/en](http://sem.ee/en/))


Copyright (c) 2009-2010 [Dmitry Polushkin], released under the MIT license