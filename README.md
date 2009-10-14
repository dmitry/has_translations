HasTranslations
===============

This simple plugin creates translations for your model.


Example
=======

For example you have Article model. You want to have title and text to be translated.

Create model named ArticleTranslation (Rule: [CamelCaseModelName]Translation)

Migration should have locale as a string with two letters and belongs_to associative id, like:

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

Add to article model "translations :value, value2"

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

You can use text filtering plugins, like acts_as_textiled and validations.
No restrictions at all. Please, give me an example... sure:


    class ArticleTranslation < ActiveRecord::Base
      acts_as_textiled :title, :text

      validates_presence_of :title, :text
      validates_length_of :title, :maximum => 100
    end

Options:

:fallback => true [default: false] - use fallback using this steps: 1) default scope; 2) first from translations; 3) empty string

PS
==

Plugin also have small addon to I18n gem. You can define your own available_locales through:

    I18n.available_locales = :en, :ru, :de

And get those values through:

    I18n.available_locales

This is done because of some plugins have own (for example ActiveScaffold has "ru, es, hu" in-box) locales. To override this, you can place I18n.available_locales= to your environment.rb file, eg.:

    I18n.available_locales = :en, :ru, :ee

TODO
====

* model and migration generators
* optimization using :include and :conditions
* caching
* write more examples: fallback feature
* write blog post about comparison and benefits of this plugin between another translation model plugins


Alternatives
============

I know three of them:

* [globalite2](http://github.com/joshmh/globalize2)
* [model_translations](http://github.com/janne/model_translations)
* [translatable_columns](http://github.com/iain/translatable_columns)


Used in
=======

* [sem.ee](http://sem.ee)


Copyright (c) 2009 [Dmitry Polushkin], released under the MIT license