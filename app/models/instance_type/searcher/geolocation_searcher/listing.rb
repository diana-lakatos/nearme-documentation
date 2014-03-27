class InstanceType::Searcher::GeolocationSearcher::Listing
  include InstanceType::Searcher::GeolocationSearcher

  def initialize(params)
    set_options_for_filters
    @params = params
    @results = fetcher.listings
  end

  def filters
    search_filters = {}
    search_filters[:listing_type_filter] = @params[:listing_types_ids].map { |lt| ListingType.find(lt).name } if @params[:listing_types_ids]
    search_filters[:location_type_filter] = @params[:location_types_ids].map { |lt| LocationType.find(lt).name } if @params[:location_types_ids]
    search_filters[:industry_filter] = @params[:industries_ids].map { |i| Industry.find(i).name } if @params[:industries_ids]
    search_filters
  end

end
