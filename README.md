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



TODO
====

* model and migration generators
* optimization using :include and :conditions
* write more examples
* write blog post about comparison and benefits of this plugin between another translation model plugins


Alternatives
============

I know three of them:

* globalite2
* ...
* ...


Used in
=======

* http://sem.ee


Copyright (c) 2009 [Dmitry Polushkin], released under the MIT license
