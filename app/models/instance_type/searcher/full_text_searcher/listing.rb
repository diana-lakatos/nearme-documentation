class InstanceType::Searcher::FullTextSearcher::Listing
  include InstanceType::Searcher::FullTextSearcher

  def initialize(params)
    set_options_for_filters
    @params = params
    @results = Transactable.where("CAST(avals(properties) AS text) @@ :q", q: params['loc'])
  end

  def filters
    search_filters = {}
    search_filters[:listing_type_filter] = @params[:listing_types_ids]
    search_filters[:location_type_filter] = @params[:location_types_ids].map { |lt| LocationType.find(lt).name } if @params[:location_types_ids]
    search_filters[:industry_filter] = @params[:industries_ids].map { |i| Industry.find(i).name } if @params[:industries_ids]
    search_filters
  end

end
