# frozen_string_literal: true
class SearcherDrop < BaseDrop
  attr_reader :original_results, :search, :searcher

  delegate :query, :input_value, :category_ids, :categories, :category_options,
           :keyword, :located, :offset, :min_price, :current_min_price, :current_max_price,
           :transactable_type, :max_price, :result_count, :located, :filterable_custom_attributes,
           :keyword, :searchable_categories, to: :searcher

  delegate :next_page, :previous_page, :total_pages, :total_entries, :offset, :current_page, :per_page, to: :original_results

  delegate :lgpricing_filters, :lntype, :category_ids, :lgpricing, :lg_custom_attributes, :display_dates,
           :start_date, :end_date, :sort, to: :search

  def initialize(searcher)
    @searcher = searcher
    @original_results = searcher.results
    @search = searcher.search
  end

  def lg_custom_attributes_hash
    @search.lg_custom_attributes.stringify_keys
  end

  def results
    @searcher.results.map(&:to_liquid)
  end

  def number_of_results
    [total_entries, (per_page * current_page)].min
  end

  def meta_description
    @context.registers[:action_view].meta_description_for_search(PlatformContext.current, @searcher.search)
  end

  def meta_title
    @context.registers[:action_view].meta_title_for_search(PlatformContext.current, @searcher.search)
  end

  def filterable_custom_attributes_hash
    filterable_custom_attributes.each_with_object({}) { |ca, hash| hash[ca.name] = ca }
  end
end
