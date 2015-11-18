class ServiceTypeDecorator < TransactableTypeDecorator
  include Draper::LazyHelpers

  delegate_all

  def display_location_type_filter?
    search_location_type_filter && PlatformContext.current.instance.location_types.count > 1
  end

  def search_field_placeholder
    searcher_type == 'fulltext' ? I18n.t('homepage.search_field_placeholder.full_text') : I18n.t('homepage.search_field_placeholder.location')
  end

end