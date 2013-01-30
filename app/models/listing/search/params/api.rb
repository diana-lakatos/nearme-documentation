class Listing::Search::Params::Api < Listing::Search::Params
  def initialize(options, geocoder=nil)
    super
    raise Listing::Search::SearchTypeNotSupported unless valid_search_method?
  end

  def valid_search_method?
    options.has_key?(:query) || options.has_key?(:boundingbox) || options.has_key?(:location)
  end

  # location[:lat], location[:lon] are actually the location of the user, not a 'search for this midpoint'
  # The API doesn't actually provide a midpoint?
  def provided_midpoint
    [nil, nil]
  end
end
