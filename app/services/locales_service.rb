class LocalesService
  def initialize(platform_context = nil, options = {})
    @platform_context = platform_context
    @options = options
  end

  def get_locales
    default_and_custom_translations = Translation.default_and_custom_translations_for_instance(@platform_context.instance.id)
    default_and_custom_translations = default_and_custom_translations.where("key ilike ?", "%#{@options[:q]}%") if @options[:q].present?
    default_and_custom_translations
  end
end
