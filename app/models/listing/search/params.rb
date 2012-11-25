require 'active_support/core_ext'
class Listing::Search::Params
  DEFAULT_SEARCH_RADIUS = 15_000.0

  attr_accessor :user, :allowed_organizations, :availability, :geocoder, :price,
    :organizations, :amenities, :options, :search_area, :midpoint

  def initialize(options, geocoder=nil)
    @geocoder = geocoder || Listing::Search::Geocoder.new
    process_options(options)
  end

  def to_scope
    scope = {}
    scope[:with] = {
        deleted_at: 0,
        organization_ids: allowed_organizations
    }

    if search_area
      scope[:geo] = search_area.radians
      scope[:with]["@geodist"] = 0.0...search_area.radius
    end
    scope
  end

  def query
    search_area ? nil : @query
  end

  private

  def build_search_area
    return if search_area
    if query
      build_search_area_from_query
    elsif midpoint?
      build_search_area_from_midpoint
    end
  end


  def midpoint?
    provided_midpoint.none?(&:nil?)
  end

  def boundingbox?
    provided_boundingbox.none?(&:nil?)
  end

  def process_options(opts)
    @options = opts.respond_to?(:deep_symbolize_keys) ? opts.deep_symbolize_keys : opts
    @user = options.fetch(:user, nil) ||  NullUser.new
    @allowed_organizations = user.organization_ids.push(0)
    @availability = options[:availability].present?  ? Availability.new(options[:availability]) : NullAvailability.new
    @amenities = options[:amenities].present? ? options[:amenities].map(&:to_i) : []
    @organizations = options[:organizations].present? ? options[:organizations].map(&:to_i) : []
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
    @search_area = Listing::Search::Area.new(midpoint, radius)
  end

  def build_search_area_from_query
  end
end
