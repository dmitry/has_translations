# TODO remove when i18n version > 0.2 will be bundled with rails (rails 3.0)
module ::I18n
  class << self
    def available_locales
      @@available_locales ||= backend.available_locales
    end

    def available_locales=(locales)
      @@available_locales = locales
    end
  end
end