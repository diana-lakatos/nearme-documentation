class InstanceType::Searcher::FullTextSearcher::Listing
  include InstanceType::Searcher::FullTextSearcher

  def initialize(transactable_type, params)
    @transactable_type = transactable_type
    set_options_for_filters
    params.delete :query
    @params = params
    scoped_transactables  = @transactable_type.transactables.searchable
    if params['loc'].present?
      scoped_transactables = scoped_transactables.where("CAST(avals(properties) AS text) @@ :q", q: params['loc'])
    end
    @results = scoped_transactables
  end

  def filters
    search_filters = {}
    search_filters[:attribute_filter] = @params[:attribute_values]
    search_filters[:listing_type_filter] = @params[:listing_types_ids]
    search_filters[:location_type_filter] = @params[:location_types_ids].map { |lt| LocationType.find(lt).name } if @params[:location_types_ids]
    search_filters[:industry_filter] = @params[:industries_ids].map { |i| Industry.find(i).name } if @params[:industries_ids]
    search_filters
  end

end
