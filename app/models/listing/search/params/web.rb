class Listing::Search::Params::Web < Listing::Search::Params
  attr :location_string
  attr_reader :listing_types_ids, :location_types_ids, :industries_ids, :lntype, :lgtype, :lgpricing, :lntypes, :sort

  def initialize(options)
    super
    @location_types_ids = @options[:location_types_ids]
    @listing_types_ids = @options[:listing_types_ids]
    @lntype = @options[:lntype].blank? ? nil : @options[:lntype]
    @lgtype = @options[:lgtype].blank? ? nil : @options[:lgtype]
    @lgpricing = @options[:lgpricing]
    @sort = @options.fetch(:sort, 'relevance').inquiry
  end

  def bounding_box
    @bounding_box ||= [[@options[:nx], @options[:ny]], [@options[:sx], @options[:sy]]] if @options[:nx].present?
    super
  end

  def midpoint
    super
    @midpoint ||= [@options[:lat], @options[:lng]] if @options[:lat].present?
    @midpoint
  end

  def get_address_component(val, name_type = :long)
    if location.present?
      location.fetch_address_component(val, name_type)
    else
      options[val.to_sym]
    end
  end

  def street
    get_address_component("street")
  end

  def suburb
    get_address_component("suburb")
  end

  def city
    get_address_component("city")
  end

  def state
    get_address_component("state")
  end

  def state_short
    get_address_component("state", :short)
  end

  def country
    get_address_component("country")
  end

  def is_united_states?
    query.to_s.downcase.include?('united states') || country == 'United States'
  end

  def postcode
    get_address_component("postcode")
  end

  def lntypes
    return [] if @lntype.nil?
    @lntypes ||= LocationType.where('lower(name) = any(array[?])', @lntype.to_s.split(','))
  end

  def lntypes_filters
    lntypes.map(&:name).map(&:downcase)
  end

  def location_types_ids
    @location_types_ids.presence || (lntypes.empty? ? nil : lntypes)
  end

  def lgtypes
    return [] if @lgtype.nil?
    @lgtypes ||= ListingType.where('lower(name) = any(array[?])', @lgtype.to_s.split(','))
  end

  def lgtypes_filters
    lgtypes.map(&:name).map(&:downcase)
  end

  def listing_types_ids
    @listing_types_ids.presence || (lgtypes.empty? ? nil : lgtypes)
  end

  def lgpricing_filters
    @lgpricing.to_s.split(',')
  end
end
