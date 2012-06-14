module HasTranslations
  class Railtie < Rails::Railtie
    initializer 'has_translations.model_additions' do
      ActiveSupport.on_load :active_record do
        include ModelAdditions
      end
    end
  end
end
