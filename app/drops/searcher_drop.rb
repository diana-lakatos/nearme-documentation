# frozen_string_literal: true
class SearcherDrop < BaseDrop
  # @return [Array<Object>] results for the search
  attr_reader :original_results
  # @return [Listing::Search::Params::Web, Object] representation of the search
  attr_reader :search_form
  # @return [Object] searcher object
  attr_reader :searcher

  # @!method query
  #   @return [String, nil] query string or nil
  # @!method input_value
  #   @return [String] value for the input with the given name
  # @!method category_ids
  #   @return [Array<String,Integer>] array of searched for categories
  # @!method categories
  #   @return [Array<CategoryDrop>] array of searched for categories
  # @!method category_options
  #   @return [Array<Array<(Integer, String)>>] array of the form [[category_id, category_name_taken_from_translations], ...]
  # @!method keyword
  #   @return [String, nil] query keyword
  # @!method located
  #   @return [Boolean] whether search is geolocated
  # @!method offset
  #   @return [Integer] search offset (with what result number we're starting)
  # @!method min_price
  #   @return [Integer] minimum price requested for the search
  # @!method current_min_price
  #   @return [Boolean] whether a minimum price was requested for the query
  # @!method current_max_price
  #   @return [Boolean] whether a maximum price was requested for the query
  # @!method transactable_type
  #   @return [TransactableTypeDrop] transactable type object associated with the query
  # @!method max_price
  #   @return [Float] maximum price requested for the query
  # @!method result_count
  #   @return [Integer] total number of results returned
  # @!method filterable_custom_attributes
  #   @return [Array<CustomAttributeDrop>] custom attributes that this query can be filtered by
  # @!method searchable_categories
  #   @return [Array<CategoryDrop>] categories that this search can be filtered by
  delegate :query, :input_value, :category_ids, :categories, :category_options,
           :keyword, :located, :offset, :min_price, :current_min_price, :current_max_price,
           :transactable_type, :max_price, :result_count, :located, :filterable_custom_attributes,
           :keyword, :searchable_categories, to: :searcher

  # @!method next_page
  #   @return [Integer] the number of the next page
  # @!method previous_page
  #   @return [Integer] the number of the previous page
  # @!method total_pages
  #   @return [Integer] total number of pages
  # @!method total_entries
  #   @return [Integer] total number of results
  # @!method offset
  #   @return [Integer] search offset (with what result number we're starting)
  # @!method current_page
  #   @return [Integer] current page number
  # @!method per_page
  #   @return [Integer] number of results per page
  delegate :next_page, :previous_page, :total_pages, :total_entries, :offset, :current_page, :per_page, to: :original_results

  # @!method lgpricing_filters
  #   @return [Array<String>] array of pricing type filters (e.g. daily, weekly, hourly etc.)
  # @!method lntype
  #   @return [Integer] location type id
  # @!method category_ids
  #   @return [Array<String, Integer>] array of searched for category ids
  # @!method lgpricing
  #   @return [String] type of pricing (e.g. daily, weekly, hourly etc.)
  # @!method lg_custom_attributes
  #   @return [Hash{Symbol => Array}] hash of custom attributes filtering the search
  #     of the form e.g. !{:attribute_name=>["Some Attribute Value"], :other_attribute_name=>[]}
  # @!method display_dates
  #   @return [Hash{Symbol => nil, String}] start/end time to filter search by
  # @!method start_date
  #   @return [String] start date to filter the search by
  # @!method end_date
  #   @return [String] end date to filter the search by
  # @!method sort
  #   @return [String] ordering rule (e.g. 'relevance')
  delegate :lgpricing_filters, :lntype, :category_ids, :lgpricing, :lg_custom_attributes, :display_dates,
           :start_date, :end_date, :sort, to: :search_form

  def initialize(searcher)
    @searcher = searcher
    @original_results = searcher.results
    @search_form = searcher.search_form
  end

  # @return [Hash{String => Array}] hash of custom attributes filtering the search
  #   of the form e.g. !{:attribute_name=>["Some Attribute Value"], :other_attribute_name=>[]}
  def lg_custom_attributes_hash
    @search_form.lg_custom_attributes.stringify_keys
  end

  # @return [Array<BaseDrop>] result items as drops
  def results
    @searcher.results.map(&:to_liquid)
  end

  # @return [Integer] minimum between total_entries and total results up and including the current page
  def number_of_results
    [total_entries, (per_page * current_page)].min
  end

  # @return [String] meta description for the current search page
  # @todo - document with example
  def meta_description
    @context.registers[:action_view].meta_description_for_search(PlatformContext.current, @searcher.search)
  end

  # @return [String] meta title for the current search page
  # @todo - document with example
  def meta_title
    @context.registers[:action_view].meta_title_for_search(PlatformContext.current, @searcher.search)
  end

  # @return [Hash<String => CustomAttributeDrop>] hash of attributes that this search can be filtered by of the
  #   form !{ custom_attribute_name => CustomAttributeDrop }
  # @todo - document with example. Rename?
  def filterable_custom_attributes_hash
    filterable_custom_attributes.each_with_object({}) { |ca, hash| hash[ca.name] = ca }
  end

  # @return [Hash{String => Array<Array<String, String>>}] hash of the form !{ field_name => [[bucket_label, bucket_key], [bucket_label, bucket_key]]
  def options_for_select
    @options_for_select = Elastic::Aggregations::OptionsForSelect
                          .prepare(@searcher.fetcher.aggregations)
  end
end
