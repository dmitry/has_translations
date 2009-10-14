require File.dirname(__FILE__) + '/test_helper'

class HasTranslationsTest < Test::Unit::TestCase
  load_schema

  class ArticleTranslation < ActiveRecord::Base
  end

  class Article < ActiveRecord::Base
    translations :description, :text
  end

  class TeamTranslation < ActiveRecord::Base
  end

  class Team < ActiveRecord::Base
    translations :text, :fallback => true
  end

  def setup
    [Article, ArticleTranslation, Team, TeamTranslation].each do |k|
      k.delete_all
    end
    I18n.locale = :ru
  end

  def test_schema_has_loaded_correctly
    [Article, ArticleTranslation, Team, TeamTranslation].each do |k|
      assert_equal [], k.all
    end
    assert_equal :ru, I18n.locale
  end

  def test_get_text_for_a_given_locale
    article = Article.create!
    article_translation = ArticleTranslation.create!(:article => article, :locale => 'en', :description => 'desc', :text => 'text')
    assert_not_equal article.text, article_translation.text
    I18n.locale = :en
    assert_equal article.text, article_translation.text
  end

  def test_translations_association_and_translations
    article = Article.create!
    assert_equal [], article.translations
    article_translation = ArticleTranslation.create!(:article => article, :locale => 'ru', :description => 'описание', :text => 'текст')
    assert_equal [], article.translations
    assert_equal [article_translation], article.reload.translations
    assert_equal 'текст', article.text
    I18n.locale = :en
    assert_equal '', article.text
    assert_equal article_translation, article.translation('ru')
    assert_equal article_translation, article.translation(:ru)
    assert article.destroy
    assert_equal [], ArticleTranslation.all
  end

  def test_translation_validations
    article_translation = ArticleTranslation.create(:description => 'description', :text => 'text')
    assert !article_translation.errors[:article].blank?
    assert !article_translation.errors[:locale].blank?
  end

  def test_fallback_options
    team = Team.create!
    assert_equal '', team.text
    team_translation = TeamTranslation.create!(:team => team, :locale => 'en', :text => 'text')
    assert_equal team_translation.text, team.text
  end

  def test_i18n_available_locales
    assert_not_equal [:xx], I18n.available_locales
    I18n.available_locales = :xx
    assert_equal :xx, I18n.available_locales
    I18n.available_locales = :xx, :xy
    assert_equal [:xx, :xy], I18n.available_locales
  end
end
