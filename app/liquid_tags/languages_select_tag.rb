class LanguagesSelectTag < SelectTag
  def name
    'locales[languages_select]'
  end

  def collection(context: nil)
    original_path = context.registers.try('[]', :controller).try(:request).try(:original_fullpath) || '/'
    default_url = Locale.change_locale_in_url(original_path, I18n.locale)

    options = Locale.all.order(:id).collect do |locale|
      name = Locale.change_locale_in_url(original_path.dup, locale.code.to_s)
      value = locale.custom_name.presence || locale.code

      [name, value]
    end

    options_from_collection_for_select(options, :first, :second, default_url)
  end

  def classes
    %w(locales_languages_select)
  end
end
