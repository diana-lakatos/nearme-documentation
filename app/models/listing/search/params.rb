require 'active_support/core_ext'
class Listing::Search::Params
  DEFAULT_SEARCH_RADIUS = 15_000.0

  attr_accessor :user, :allowed_organizations, :availability, :geocoder, :price,
    :organizations, :amenities, :options, :search_area, :midpoint, :query

  def initialize(options, geocoder=nil)
    @geocoder = geocoder || Listing::Search::Geocoder.new
    process_options(options)
    build_search_area
  end

  def to_scope
    scope = {}
    scope[:with] = {
        deleted_at: 0,
        organization_ids: allowed_organizations
    }

    scope[:per_page] = 100

    if search_area
      scope[:geo] = search_area.radians
      scope[:with]["@geodist"] = 0.0...search_area.radius
    end

    scope
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

  private

  def build_search_area
    return if search_area

    build_search_area_from_midpoint
    build_search_area_from_query if !search_area && query
  end

  def midpoint?
    provided_midpoint.none?(&:blank?)
  end

  def boundingbox?
    provided_boundingbox.none?(&:blank?)
  end

  def provided_boundingbox
    box = options.fetch(:boundingbox, { start: { lat: nil, lon: nil }, end: { lat: nil, lon: nil } })
    [box[:start][:lat], box[:start][:lon], box[:end][:lat], box[:end][:lon]]
  end

  def provided_midpoint
    location = options.fetch(:location, { lon: nil, lat: nil })
    [location[:lat], location[:lon]]
  end

  def process_options(opts)
    @options = opts.respond_to?(:deep_symbolize_keys) ? opts.deep_symbolize_keys : opts
    @user = options.fetch(:user, nil) ||  NullUser.new
    @allowed_organizations = user.organization_ids.push(0)
    @availability = options[:availability].present?  ? Availability.new(options[:availability]) : NullAvailability.new
    @amenities = options[:amenities].present? ? options[:amenities].map(&:to_i) : []
    @organizations = options[:organizations].present? ? options[:organizations].map(&:to_i) : []
    @query = @location_string = options.fetch(:query, nil) || options.fetch(:q, nil) || options.fetch(:address, nil)
    @found_location = false
    build_price_from_options
  end

  def build_price_from_options
    if options[:price].present?
      @price = PriceRange.new(options[:price][:min], options[:price][:max])
    else
      @price = NullPriceRange.new
    end
  end

  def radius
    @radius || Listing::Search::Params::DEFAULT_SEARCH_RADIUS
  end

  def build_search_area_from_midpoint
    if boundingbox?
      @midpoint = Midpoint.new(*provided_boundingbox).center
      @radius = @midpoint.distance_from(provided_boundingbox.slice(0,2))
    elsif midpoint?
      @midpoint = Coordinate.new(*provided_midpoint)
    end

    if @midpoint
      @found_location = true
      @search_area = Listing::Search::Area.new(midpoint, radius)
    end
  end

  def build_search_area_from_query
    @search_area = geocoder.find_location(query)
    if @search_area
      @found_location = true
      @location_string = geocoder.pretty
      @query = nil
    end
  end
end
