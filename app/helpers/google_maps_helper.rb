module GoogleMapsHelper
  def google_maps_streetview_url(options = {})
    params = google_maps_params(options.merge(
      :location_type => :location
    ))

    google_maps_api_url('streetview', params)
  end

  def google_maps_road_map_url(options = {})
    params = google_maps_params(options.merge(
      :location_type => :center,
      :zoom => 16,
    ))
    params[:markers] = "color:green|size:small|#{params[:center]}"

    google_maps_api_url('staticmap', params)
  end

  private

  def google_maps_params(options = {})
    options = options.reverse_merge(
      width: 640,
      height: 480,
      sensor: 'false'
    )

    latitude = options.delete(:latitude) || options.delete(:lat)
    longitude = options.delete(:longitude) || options.delete(:lng) || options.delete(:lon)
    location_type = options.delete(:location_type)

    width = options.delete(:width)
    height = options.delete(:height)
    sensor = options.delete(:sensor).present?.to_s

    params = options.merge({ :sensor => sensor, :size => "#{width}x#{height}"})
    params[location_type] = "#{latitude},#{longitude}" if location_type
    params
  end

  def google_maps_api_url(endpoint, params = {})
    "http#{'s' if request.ssl?}://maps.googleapis.com/maps/api/#{endpoint}?#{params.to_query}"
  end
end