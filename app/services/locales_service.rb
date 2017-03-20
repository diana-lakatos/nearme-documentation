class LocalesService
  DATETIME_TRANSLATIONS = %w(
    datepicker.dformat
    datepicker.pformat
    timepicker.dformat
    timepicker.pformat
    timepicker.jsformat
    dayViewHeaderFormat

    time.formats.short
    time.formats.long
    time.formats.with_time_zone
    time.formats.short_with_time_zone

    date.yesterday
    date.formats.long
    date.formats.short
    date.formats.day_and_month
  ).freeze

  def initialize(args = {})
    @platform_context = args[:platform_context]
    @query = args[:query]
    @locale = args[:locale].presence || platform_context.instance.primary_locale
    @case_sensitive = args[:case_sensitive]
    @match_whole_words = args[:match_whole_words]
  end

  def get_locales
    default_and_custom_translations = Translation.default_and_custom_translations_for_instance(@platform_context.instance.id, @locale)
    default_and_custom_translations = default_and_custom_translations.where("key #{regex_operator} ? OR value #{regex_operator} ?", query_value, query_value) if @query.present?
    default_and_custom_translations
  end

  private

  def regex_operator
    @case_sensitive ? '~' : '~*'
  end

  def query_value
    @match_whole_words ? "\\y#{@query}\\y" : @query
  end

end
