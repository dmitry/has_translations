ActiveRecord::Schema.define(:version => 0) do
  create_table :articles, :force => true do |t|
    t.string :title
  end

  create_table :article_translations, :force => true do |t|
    t.references :article, :null => false
    t.string :locale, :null => false, :limit => 2
    t.string :description
    t.text :text
  end

  create_table :teams, :force => true do |t|
    t.string :title
  end

  create_table :team_translations, :force => true do |t|
    t.references :team, :null => false
    t.string :locale, :null => false, :limit => 2
    t.text :text
  end

  create_table :organizations, :force => true do |t|
    t.string :title
  end

  create_table :organization_translations, :force => true do |t|
    t.integer :company_id, :null => false
    t.string :locale, :null => false, :limit => 2
    t.text :text
  end
end

class ArticleTranslation < ActiveRecord::Base
  #attr_accessible :description, :text
end
class Article < ActiveRecord::Base
  include HasTranslations::ModelAdditions

  has_translations :description, :text, :writer => true
end

class TeamTranslation < ActiveRecord::Base
end
class Team < ActiveRecord::Base
  include HasTranslations::ModelAdditions

  has_translations :text, :fallback => true, :nil => nil
end

class OrganizationTranslation < ActiveRecord::Base
end
class Organization < ActiveRecord::Base
  include HasTranslations::ModelAdditions

  has_translations :text, :writer => true, :foreign_key => 'company_id'
end
