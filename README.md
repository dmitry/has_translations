HasTranslations v1.0.0
==============================

[![Build Status](https://secure.travis-ci.org/dmitry/has_translations.png?branch=master)](http://travis-ci.org/dmitry/has_translations) [![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/dmitry/has_translations/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

This simple plugin creates translations for your model.
Uses delegation pattern: http://en.wikipedia.org/wiki/Delegation_pattern

Tested with ActiveRecord versions: 3.1.x, 3.2.x, 4.0.x
And tested with ruby 1.8.7 (ree), 1.9.3, 2.0.0

Compatibility
=============

This version only support Rails 4.0.x and 3.x.x. For Rails 2.3.x support please get the 0.3.5 version of this gem.
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

Run in command line:

    rails g translation_for article title:string text:text

It will produce ArticleTranslation model and migration.

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

* `:fallback => true` [default: false] - fallback 1) default locale; 2) first from translations;
* `:reader => false` [default: true] - add reader to the model object
* `:writer => true` [default: false] - add writer to the model object
* `:autosave => true` [default: false] - use [autosave option](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many) for the ActiveRecord translations relation
* `:nil => nil` [default: ''] - if no model found by default returns empty string, you can set it for example to `nil` (no `lambda` supported)

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

* caching
* write more examples: fallback feature
* write blog post about comparison and benefits of this plugin between another translation model plugins


Alternatives
============

I know three of them:

* [globalize3](https://github.com/svenfuchs/globalize3) - Globalize3 is the successor of Globalize for Rails.
* [puret](http://github.com/jo/puret) - special for Rails 3 and almost the same as this project.
* [model_translations](http://github.com/janne/model_translations) - almost the same as this project, but more with more code in lib.
* [translatable_columns](http://github.com/iain/translatable_columns) - different approach: every column have own postfix "_#{locale}" in the same table (sometimes it could be fine).


Copyright (c) 2009-2013 [Dmitry Polushkin], released under the MIT license
