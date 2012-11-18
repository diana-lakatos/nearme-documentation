class Listing::Search::Params::Api < Listing::Search::Params
  def initialize(options, geocoder=nil)
    super
    raise Listing::Search::SearchTypeNotSupported unless valid_search_method?
    @query = options[:query]
    build_search_area
  end

  def valid_search_method?
    options.has_key?(:query) || options.has_key?(:boundingbox) || options.has_key?(:location)
  end

  def build_search_area_from_query
    @search_area = geocoder.find_location(query)
  end

  def provided_boundingbox
    box = options.fetch(:boundingbox, { start: { lat: nil, lon: nil }, end: { lat: nil, lon: nil } })
    [box[:start][:lat], box[:start][:lon], box[:end][:lat], box[:end][:lon]]
  end

  def provided_midpoint
    location = options.fetch(:location, { lon: nil, lat: nil })
    [location[:lat], location[:lon]]
  end

end
