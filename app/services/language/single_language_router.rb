class Language::SingleLanguageRouter
  attr_reader :language_param

  def initialize(language_param)
    @language_param = language_param
  end

  def redirect?
    language_param.present?
  end

  def url_params
    { language: nil }
  end

end
