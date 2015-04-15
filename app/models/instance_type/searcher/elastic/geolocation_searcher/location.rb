class InstanceType::Searcher::Elastic::GeolocationSearcher::Location
  include InstanceType::Searcher::Elastic::GeolocationSearcher

  def initialize(transactable_type, params)
    @transactable_type = transactable_type
    set_options_for_filters
    @params = params
    scoped_transactables = []

    fetcher.to_a.map do |f|
      scoped_transactables << ::Location.where(id: f['_source']['location_id'].to_i).first
    end
    scoped_transactables.uniq!
    @search_results_count = scoped_transactables.count
    @results = scoped_transactables
  end

  def filters
    search_filters = {}
    search_filters[:location_type_filter] = search.location_types_ids.map { |lt| lt.respond_to?(:name) ? lt.name : lt } if search.location_types_ids && !search.location_types_ids.empty?
    search_filters[:listing_pricing_filter] = search.lgpricing_filters if not search.lgpricing_filters.empty?
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters
  end

  private

  def initialize_search_params
    { instance_id: PlatformContext.current.instance.id, transactable_type_id: @transactable_type.id }
  end

end