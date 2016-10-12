class Language::MultiLanguageRouter
  attr_reader :language_param, :current_locale

  def initialize(language_param, current_locale)
    @language_param = language_param
    @current_locale = current_locale
  end

  def redirect?
    language_param.to_s != current_locale.to_s
  end

  def url_params
    { language: current_locale }
  end
end
