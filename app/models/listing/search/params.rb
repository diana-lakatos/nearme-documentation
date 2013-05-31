require 'active_support/core_ext'

class Listing::Search::Params
  DEFAULT_SEARCH_RADIUS = 150.0 # in miles
  MIN_SEARCH_RADIUS = 7.0 # in miles

  attr_accessor :geocoder
  attr_reader :availability, :price, :amenities, :options, :search_area, :midpoint, :bounding_box, :location

  def initialize(options)
    @geocoder = Listing::Search::Geocoder
    @options = options.respond_to?(:deep_symbolize_keys) ? options.deep_symbolize_keys : options.symbolize_keys

    if !midpoint && query.present?
      @location = @geocoder.find_search_area(query)
      if @location.present?
        @bounding_box, @midpoint, @radius = @location.bounds, @location.center, @location.radius
      end
    end

    @availability = if @options[:availability].present?
      Availability.new(@options[:availability])
    else
      NullAvailability.new
    end

    @amenities = [*@options[:amenities]].map(&:to_i)

    @price = if @options[:price].present?
      PriceRange.new(@options[:price][:min], @options[:price][:max])
    else
      NullPriceRange.new
    end
  end

  def query
    @options[:query] || @options[:q] || @options[:address]
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

  def available_dates
    availability.dates
  end

end
