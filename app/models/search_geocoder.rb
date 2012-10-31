class SearchGeocoder

  attr :geo_params

  def found_location?
    @geo_params.has_key? :midpoint
  end

  def build_geocoded_data_from_string(location)
    @geo_params = {}
    geocoded = Geocoder.search(location).try(:first)
    return if geocoded.nil?
    loc = geocoded.data
    geometry = loc['geometry']

    geo_params[:pretty] = loc['formatted_address']
    geo_params[:midpoint] = [geometry['location']['lat'], geometry['location']['lng']]

    bounds = geometry['bounds']
    if bounds && (loc['types'] == ["country","political"]) || (loc['types'] == ["administrative_area_level_1","political"])
      geo_params[:boundingbox] = {
        :start => {
          :lat => bounds['northeast']['lat'].to_f,
          :lon => bounds['northeast']['lon'].to_f
        },
        :end => {
          :lat => bounds['southwest']['lat'].to_f,
          :lon => bounds['southwest']['lon'].to_f
        }
      }
    end
    geo_params

  end

end
