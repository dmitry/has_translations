HasTranslations v1.0.0.alpha.1
==============================

This simple plugin creates translations for your model.
Uses delegation pattern: http://en.wikipedia.org/wiki/Delegation_pattern

Tested with ActiveRecord versions: 3.0.0, 3.1.0, 3.2.0 (to test with Rails 3.1 run `rake RAILS_VERSION=3.1`)
And tested with ruby 1.8.7, 1.9.2, 1.9.3

Compatibility
=============

This version only support Rails 3.x.x. For Rails 2.3.x support please get the 0.3.5 version of this gem.
Plugin support is deprecated in Rails and will be removed soon so this version drop plugin support.
To prevent method shadowing between "translations" class method and "translations" relation in models the class
method has been renamed has_translations.

    class Article < ActiveRecord::Base
      translations :title, :text
    end

become

    class Article < ActiveRecord::Base
      has_translations :title, :text
    end

Installation
============

    gem install has_translations

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
      has_translations :title, :text
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
* :autosave => true [default: false] - use [autosave option](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many) for the ActiveRecord translations relation
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

named_scope `translated(locale)` - with that named_scope you can find only
those models that is translated only to specific locale. For example if you will
have 2 models, one is translated to english and the second one isn't, then it
`Article.translated(:en)` will find only first one.

TODO
====

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

[noch.es](http://noch.es/), [eten.es](http://www.eten.es), [sem.ee](http://sem.ee/)


Copyright (c) 2009-2010 [Dmitry Polushkin], released under the MIT license
