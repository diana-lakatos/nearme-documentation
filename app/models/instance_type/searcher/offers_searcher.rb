class InstanceType::Searcher::OffersSearcher
  #TODO remove InstanceType::Searcher if not needed
  include InstanceType::Searcher

  attr_reader :search, :filterable_custom_attributes

  def initialize(transactable_type, params)
    @params = params
    @results = fetcher
    @transactable_type = transactable_type
    set_options_for_filters
  end

  def fetcher
    @fetcher  = Offer.active.search_by_query([:name, :description, :summary], @params[:query])
    @fetcher.includes(:creator)
  end

  def search_query_values
    {
      query: @params[:query]
    }
  end

  #TODO remove search if not needed
  def search
    @search ||= Spree::Product::Search::Params::Web.new(@params)
  end

  def set_options_for_filters
    @filterable_custom_attributes = @transactable_type.custom_attributes.searchable
  end

  def to_event_params
    { search_query: query, result_count: result_count }
  end

end
