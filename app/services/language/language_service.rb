class Language::LanguageService

  attr_reader :language_params, :fallback_languages, :available_languages

  def initialize(language_params = [], fallback_languages = [], available_languages = [])
    @language_params = clean_language_codes(language_params)
    @fallback_languages = clean_language_codes(fallback_languages)
    @available_languages = clean_language_codes(available_languages)
  end

  def get_language
    find_valid_locale(language_params) || find_valid_locale(fallback_languages)
  end

  private

  def find_valid_locale(locales)
    locales.find {|l| available_languages.include? l.try(:to_sym) }
  end

  def clean_language_codes(codes)
    codes.reject(&:blank?).map(&:to_sym).uniq
  end

end
