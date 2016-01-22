class LocalesService
  DATETIME_TRANSLATIONS = %w(
    datepicker.dformat
    datepicker.pformat
    timepicker.dformat
    timepicker.pformat
    dayViewHeaderFormat

    time.formats.short
    time.formats.long
    time.formats.with_time_zone

    date.yesterday
    date.formats.long
    date.formats.short
    date.formats.day_and_month
  ).freeze
  
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
