module GoogleMapsHelper
  def google_maps_streetview_url(options = {})
    options = options.reverse_merge(
      width: 640,
      height: 480,
      sensor: 'false'
    )
    options[:latitude] ||= options[:lat]
    options[:longitude] ||= options[:lng] || options[:lon]

    params = { :sensor => options[:sensor].to_s, :size => "#{options[:width]}x#{options[:height]}", :location => "#{options[:latitude]},#{options[:longitude]}"}
    "http://maps.googleapis.com/maps/api/streetview?#{params.to_query}"
  end
end