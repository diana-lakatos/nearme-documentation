require 'active_support/core_ext'

class Listing::Search::Params
  DEFAULT_SEARCH_RADIUS = 150.0 # in miles
  MIN_SEARCH_RADIUS = 7.0 # in miles

  attr_accessor :geocoder
  attr_reader :availability, :price, :amenities, :options, :search_area, :midpoint, :query, :bounding_box, :location

  def initialize(options, geocoder=nil)
    @geocoder = geocoder || Listing::Search::Geocoder
    process_options(options)
  end

  def to_args
    [midpoint, radius] if midpoint.present?
  end

  # Return whether the search params are searching for the presense of the query,
  # as keyword(s) in addition to geo/feature lookup.
  # For example, API searches can include keywords but the web UI serches are always
  # geolocation based, with no keywords.
  #
  # This method should be overriden to apply the relevant behaviour.
  def keyword_search?
    query.present?
  end

  def radius
    @radius ||= begin
      if bounding_box.present?
        ::Geocoder::Calculations.distance_between(*bounding_box) / 2
      else
        Listing::Search::Params::DEFAULT_SEARCH_RADIUS
      end
    end

    @radius > MIN_SEARCH_RADIUS ? @radius : MIN_SEARCH_RADIUS
  end

  def midpoint
    @midpoint ||= begin
      if @options[:location].present?
        [@options[:location][:lat], @options[:location][:lon]]
      elsif bounding_box.present?
        ::Geocoder::Calculations.geographic_center(bounding_box)
      end
    end
  end

  def bounding_box
    @bounding_box ||= begin
      if @options[:boundingbox].present?
        box = @options[:boundingbox]
        [[box[:start][:lat], box[:start][:lon]], [box[:end][:lat], box[:end][:lon]]]
      end
    end
  end

  def found_location?
    midpoint.present? or bounding_box.present?
  end

  private

  def process_options(opts)
    @options = opts.respond_to?(:deep_symbolize_keys) ? opts.deep_symbolize_keys : opts.symbolize_keys

    @availability = if @options[:availability].present? 
      Availability.new(@options[:availability])
    else
      NullAvailability.new
    end

    @amenities = [*@options[:amenities]].map(&:to_i)

    @query = @location_string = @options[:query] || @options[:q] || @options[:address]

    if not found_location? and query.present?
      @location = @geocoder.find_search_area(query)
      if @location.present?
        @bounding_box, @midpoint, @radius, @address_components = @location.bounds, @location.center, @location.radius, @location.address_components
      end
    end

    @price = if @options[:price].present?
      PriceRange.new(@options[:price][:min], @options[:price][:max])
    else
      NullPriceRange.new
    end

  end

end
