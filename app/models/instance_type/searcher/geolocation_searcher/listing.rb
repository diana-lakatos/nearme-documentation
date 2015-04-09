class InstanceType::Searcher::GeolocationSearcher::Listing
  include InstanceType::Searcher::GeolocationSearcher

  def initialize(transactable_type, params)
    @transactable_type = transactable_type
    set_options_for_filters
    @params = params
    scoped_transactables  = fetcher.listings
    if params['query'].present?
      query = params['query'].split(' ').join(' & ') + ":*"
      scoped_transactables = scoped_transactables.where("CAST(avals(properties) AS text) @@ to_tsquery(:q)", q: query)
    end
    @results = scoped_transactables
  end

  def filters
    search_filters = {}
    search_filters[:location_type_filter] = @params[:location_types_ids].map { |lt| LocationType.find(lt).name } if @params[:location_types_ids]
    search_filters[:industry_filter] = @params[:industries_ids].map { |i| Industry.find(i).name } if @params[:industries_ids]
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters
  end

end
