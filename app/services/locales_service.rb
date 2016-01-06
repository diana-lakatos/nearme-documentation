class LocalesService
  def initialize(platform_context = nil, locale = 'en', options = {})
    @platform_context = platform_context
    @options = options
    @locale = locale
  end

  def get_locales
    default_and_custom_translations = Translation.default_and_custom_translations_for_instance(@platform_context.instance.id, @locale)
    default_and_custom_translations = default_and_custom_translations.where("key ilike ? OR value ilike ?", "%#{@options[:q]}%", "%#{@options[:q]}%") if @options[:q].present?
    default_and_custom_translations
  end
end
