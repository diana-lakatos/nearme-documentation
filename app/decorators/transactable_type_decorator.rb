# frozen_string_literal: true
class TransactableTypeDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def fulltext_search?
    %w(fulltext fulltext_category).include?(searcher_type)
  end

  def fulltext_geo_search?
    searcher_type == 'fulltext_geo'
  end

  def fulltext_category_search?
    searcher_type == 'fulltext_category'
  end

  def geo_category_search?
    searcher_type == 'geo_category'
  end

  def display_taxonomy_tree?
    show_categories
  end

  def display_saved_search?
    allow_save_search
  end

  def search_input_name
    fulltext_search? ? 'query' : 'loc'
  end

  def other_search_view
    default_search_view == 'list' ? 'listing_mixed' : default_search_view
  end

  def geolocation_placeholder
    I18n.t "#{translation_namespace}.search_field_placeholder.location", default: I18n.t('homepage.search_field_placeholder.location')
  end

  def fulltext_placeholder
    I18n.t "#{translation_namespace}.search_field_placeholder.full_text", default: I18n.t('homepage.search_field_placeholder.full_text')
  end

  def display_location_type_filter?
    search_location_type_filter && PlatformContext.current.instance.location_types.count > 1
  end

  def search_field_placeholder
    searcher_type == 'fulltext' ? I18n.t('homepage.search_field_placeholder.full_text') : I18n.t('homepage.search_field_placeholder.location')
  end
end
