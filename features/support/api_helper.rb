module ApiHelper
  def search_for_json(json)
    update_all_indexes
    post "/v1/listings/search", json.to_json
  end

  def api_search(hash)
    @response = search_for_json(APISearchOptions.new(hash).to_hash)
  end

  def results_listings
    parse_json(last_json)["listings"].map(&:symbolize_keys)
  end
end


class APISearchOptions
  attr :options

  def initialize(hash)
    @options = hash.symbolize_keys
  end

  def to_hash
    json = {}
    json["query"] = query if has_query?
    json["boundingbox"] = bounding_box if has_bounding_box?
    json["price"] = price if has_price?
    json["organizations"] = organizations if has_organizations?
    json["quantity"] = quantities if has_quantities?
    json["dates"] = dates if has_dates?
    json
  end

  def bounding_box
    case options[:bounding_box].downcase.gsub(' ', '_').to_sym
    when :new_zealand
      {"start" => {"lat" => -32.24997,"lon" => 162.94921 }, "end" => {"lat" => -47.04018,"lon" => 180.00000 } }
    else
      {"start" => {"lat" => -180.0,"lon" => -180.0}, "end" => {"lat" => 180.0,"lon" => 180.0 } }
    end
  end

  def has_bounding_box?
    options.has_key?(:bounding_box)
  end

  def dates
    options[:dates].map(&:to_date)
  end

  def has_dates?
    options.has_key?(:dates)
  end

  def organizations
    options[:organizations].map(&:id)
  end

  def has_organizations?
    options.has_key?(:organizations)
  end

  def price
   {"min" => options[:price_min].to_i, "max" => options[:price_max].to_i }
  end

  def has_price?
    options.has_key?(:price_min) && options.has_key?(:price_max)
  end

  def quantities
    quantities = {}
    quantities["min"] = options[:desks_min] if options.has_key?(:desks_min)
    quantities["max"] = options[:desks_max] if options.has_key?(:desks_max)
    quantities
  end

  def has_quantities?
    options.has_key?(:desks_min) || options.has_key?(:desks_max)
  end

  def query
    options[:query]
  end

  def has_query?
    options.has_key?(:query)
  end

end

World(ApiHelper)
