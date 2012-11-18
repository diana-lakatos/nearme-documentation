class Listing::Search::Params::Web < Listing::Search::Params
  attr :location_string
  def initialize(options, geocoder=nil)
    super
    @found_location = false
    @query = @location_string = options[:q] || options[:address]
    extract_midpoint_from_location_string if location_string.present?
    build_search_area
  end

  def found_location?
    @found_location
  end

  def provided_boundingbox
    [options[:nx], options[:ny],options[:sx], options[:sy]]
  end

  def provided_midpoint
    [options[:lat], options[:lng]]
  end

  def extract_midpoint_from_location_string
    geocoder.build_geocoded_data_from_string(location_string)
    if geocoder.found_location?
      @found_location = true;
      @location_string = geocoder.pretty
      @search_area = geocoder.search_area
    end
  end
end
