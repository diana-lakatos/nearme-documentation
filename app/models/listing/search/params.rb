require 'active_support/core_ext'

class Listing::Search::Params
  DEFAULT_SEARCH_RADIUS = 150.0 # in miles
  MIN_SEARCH_RADIUS = 7.0 # in miles

  attr_accessor :geocoder
  attr_reader :availability, :price, :options, :search_area, :midpoint, :bounding_box, :location

  def initialize(options, _transactable_type)
    @geocoder = Listing::Search::Geocoder
    @options = options.respond_to?(:deep_symbolize_keys) ? options.deep_symbolize_keys : options.symbolize_keys

    if !midpoint && loc.present?
      @location = @geocoder.find_search_area(query)
      if @location.present?
        @bounding_box = @location.bounds
        @midpoint = @location.center
        @radius = @location.radius
      end
    end

    @availability = if @options[:availability].present?
                      Availability.new(@options[:availability])
                    else
                      NullAvailability.new
    end

    @price = if @options[:price].present?
               PriceRange.new(@options[:price][:min], @options[:price][:max])
             else
               NullPriceRange.new
    end
  end

  def query
    (@options[:loc] || @options[:q] || @options[:address] || @options[:query])
  end

  def keyword
    @options[:query][0, 200] if @options[:query]
  end

  def loc
    @options[:loc][0, 200] if @options[:loc]
  end

  def radius
    @radius ||= begin
      if bounding_box.present?
        ::Geocoder::Calculations.distance_between(bounding_box[:top_right].values, bounding_box[:bottom_left].values) / 2
      else
        Listing::Search::Params::DEFAULT_SEARCH_RADIUS
      end
    end

    @radius > MIN_SEARCH_RADIUS ? @radius : MIN_SEARCH_RADIUS
  end

  def midpoint
    @midpoint ||= begin
      if @options[:location].present? && is_numeric?(@options[:location][:lat]) && is_numeric?(@options[:location][:lon])
        [@options[:location][:lat], @options[:location][:lon]]
      elsif is_numeric?(@options[:lat]) && is_numeric?(@options[:lng])
        [@options[:lat], @options[:lng]]
      elsif bounding_box && bounding_box[:top_right][:lat] == bounding_box[:bottom_left][:lat]
        bounding_box[:top_right].values
      end
    end
  end

  def is_numeric?(str)
    str.present? && Float(str)
  rescue
    false
  end

  def bounding_box
    @bounding_box ||= begin
      if @options[:boundingbox].present?
        box = @options[:boundingbox]
        {
          top_right: box[:end],
          bottom_left: box[:start]
        }
      end
    end
    # Fixes ES exception when bounding box coordinates are provided in wrong order
    if @bounding_box && @bounding_box[:top_right][:lat] < @bounding_box[:bottom_left][:lat]
      top_right = @bounding_box[:top_right]
      @bounding_box[:top_right] = @bounding_box[:bottom_left]
      @bottom_left = top_right
    end
    @bounding_box
  end

  def available_dates
    availability.dates
  end
end
