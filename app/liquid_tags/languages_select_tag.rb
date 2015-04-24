class LanguagesSelectTag < Liquid::Tag
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper

  def initialize(tag_name, param, tokens)
    super

    @param = param
  end

  def render(context)
    original_path = context.registers.try('[]', :controller).try(:request).try(:original_fullpath) || '/'
    default_url = Locale.change_locale_in_url(original_path, I18n.locale)

    options = Locale.all.order(:id).collect do |locale|
      name = Locale.change_locale_in_url(original_path.dup, locale.code.to_s)
      value = locale.custom_name.presence || locale.code

      [name, value]
    end

    select_tag('locales[languages_select]', options_from_collection_for_select(options, :first, :second, default_url), :class => 'locales_languages_select')
  end

end

Liquid::Template.register_tag('languages_select', LanguagesSelectTag)

