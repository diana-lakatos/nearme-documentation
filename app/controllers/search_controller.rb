class SearchController < ApplicationController

  def index
    @search = find_search_query
    if @search
      @locations = Listing.search_by_location(@search)
      if @locations.any?
        @listings = Listing.where(:location_id => @locations.map(&:id)).includes(:photos).
          paginate(:page => params[:page], :per_page => 20)
      else
        @listings = []
      end
      @query = @search[:pretty]
      SearchQuery.create(:query => @search[:query], :agent => request.env['HTTP_USER_AGENT'])
    end

    if request.xhr?
      render :partial => "search/listings.html", :layout => false
    else
      render
    end
  end

  private

    def find_search_query
      query = params[:q] || params[:address]
      lat = params[:lat]
      lng = params[:lng]
      if query && !lat && !lng
        extract_search_from_geocoding(query)
      elsif query && lat && lng
        extract_search_from_params(query, lat, lng)
      end
    end

    def extract_search_from_geocoding(query)
      search = { :query => query }
      geocoded = Geocoder.search(query).try(:first)
      return search if geocoded.nil?

      loc = geocoded.data
      geometry = loc['geometry']

      search[:pretty] = loc['formatted_address']
      search[:lat] = geometry['location']['lat']
      search[:lng] = geometry['location']['lng']

      bounds = geometry['bounds']
      if bounds && (loc['types'] == ["country","political"]) || (loc['types'] == ["administrative_area_level_1","political"])
        search[:northeast] = { :lat => bounds['northeast']['lat'], :lng => bounds['northeast']['lng'] }
        search[:southwest] = { :lat => bounds['southwest']['lat'], :lng => bounds['southwest']['lng'] }
      end

      search
    end

    def extract_search_from_params(query, lat, lng)
      search = { :query => query, :lat => lat, :lng => lng }
      if params[:nx]
        search[:northeast] = { :lat => params[:nx] }
        search[:northeast][:lng] = params[:ny] if params[:ny]
      end
      if params[:sx]
        search[:southwest] = { :lat => params[:sx] }
        search[:southwest][:lng] = params[:sy] if params[:sy]
      end
      search
    end

end
