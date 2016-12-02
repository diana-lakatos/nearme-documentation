module ApiHelper
  def search_for_json(json)
    post "/v1/listings/search", json.to_json
  end

  def api_search(hash)
    @response = search_for_json(APISearchOptions.new(hash).to_hash)
  end

  def results_listings
    parse_json(last_json)["listings"].map(&:symbolize_keys)
  end

  def result
    parse_json(last_json)
  end

end


class APISearchOptions
  attr :options

  def initialize(hash)
    @options = hash.symbolize_keys
  end

  def to_hash
    json = {}
    json.merge!(query)
    json.merge!(bounding_box)
    json.merge!(price)
    json.merge!(quantities)
    json.merge!(dates)
    json
  end

  def bounding_box
    return {} unless options.has_key?(:bounding_box)

    case options[:bounding_box].downcase.gsub(' ', '_').to_sym
    when :new_zealand
      { "boundingbox" => {"end" => {"lat" => -32.31997,"lon" => -176.66016 }, "start" => {"lat" => -48.45,"lon" => 163.125 } } }
    else
      { "boundingbox" => {"start" => {"lat" => -180.0,"lon" => -180.0}, "end" => {"lat" => 180.0,"lon" => 180.0 } } }
    end
  end

  def dates
    return {} unless options.has_key?(:dates)
    { "dates" => options[:dates].map(&:to_date) }
  end

  def price
    return {} unless options.has_key?(:price_min) && options.has_key?(:price_max)
    { "price" => {"min" => options[:price_min].to_i, "max" => options[:price_max].to_i } }
  end

  def quantities
    quantities = {}
    quantities["min"] = options[:desks_min] if options.has_key?(:desks_min)
    quantities["max"] = options[:desks_max] if options.has_key?(:desks_max)
    !quantities.empty? ? { "quantity" => quantities }  : {}
  end

  def query
    options.has_key?(:query) ? { "query" => options[:query] } : {}
  end

end

World(ApiHelper)
