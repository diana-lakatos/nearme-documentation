class Listing::Search::Geocoder

  attr :geo_params, :pretty, :search_area

  def find_location(query)
    data = build_geocoded_data_from_string(query)
    return unless data
    search_area
  end

  def found_location?
    @geo_params.has_key? :midpoint
  end

  def build_geocoded_data_from_string(location)
    @geo_params = {}
    geocoded = ::Geocoder.search(location).try(:first)
    return if geocoded.nil?
    loc = geocoded.data
    geometry = loc['geometry']
    @pretty = geo_params[:pretty] = loc['formatted_address']
    geo_params[:midpoint] = [geometry['location']['lat'], geometry['location']['lng']]
    bounds = geometry.has_key?("bounds") ? geometry["bounds"] : geometry["viewport"]
    geo_params[:edge] =  bounds['southwest'].collect { |c| c[1].to_f }
    build_search_area
    geo_params
  end

  def build_search_area
    center = Coordinate.new(*geo_params[:midpoint])
    radius = center.distance_from(*geo_params[:edge])
    @search_area = Listing::Search::Area.new(center, radius)
  end

end
