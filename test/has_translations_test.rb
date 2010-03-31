require 'test_helper'

class HasTranslationsTest < Test::Unit::TestCase
  def setup
    setup_db
    
    [Article, ArticleTranslation, Team, TeamTranslation].each do |k|
      k.delete_all
    end
    I18n.available_locales = :ru, :en
    I18n.locale = :ru
  end

  def teardown
    teardown_db
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

  def test_set_text_for_a_given_locale
    article = Article.create!
    article.text = 'text'
    assert_equal 0, article.translations.count
    article.save!
    assert_equal 1, article.translations.length
    assert_equal 1, article.translations.count
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
    assert article_translation.errors[:article].present?
    assert article_translation.errors[:locale].present?
  end

  def test_fallback_options
    article = Article.create!
    assert_equal '', article.text
    team = Team.create!
    assert_equal nil, team.text
    team_translation = TeamTranslation.create!(:team => team, :locale => 'en', :text => 'text')
    assert_equal team_translation.text, team.reload.text
  end

  def test_all_translations_sorted_build_or_translation_getted
    team = Team.create!
    team_translation = TeamTranslation.create!(:team => team, :locale => 'en', :text => 'text')
    assert_equal team_translation, team.all_translations[:en]
    assert_equal 'ru', team.all_translations[:ru].locale
    team_translation_new = team.translations.build(:locale => :ru)
    assert_equal team_translation_new.locale.to_s, team.all_translations[:ru].locale
  end

  def test_all_translations_should_not_have_build_translations
    team = Team.create!
    assert_equal 0, team.translations.length
    team.all_translations
    assert_equal 0, team.translations.length
  end

  def test_has_translation?
    team = Team.create!
    assert !team.has_translation?(:en)
    team.translations.create!(:locale => 'en', :text => 'text')
    assert team.has_translation?(:en)
  end

  def test_i18n_available_locales
    assert_not_equal [:xx], I18n.available_locales
    I18n.available_locales = :xx
    assert_equal :xx, I18n.available_locales
    I18n.available_locales = :xx, :xy
    assert_equal [:xx, :xy], I18n.available_locales
  end
end
