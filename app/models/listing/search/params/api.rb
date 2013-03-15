class Listing::Search::Params::Api < Listing::Search::Params
  def initialize(options, geocoder=nil)
    super
    raise Listing::Search::SearchTypeNotSupported unless valid_search_method?
  end

  def valid_search_method?
    options.has_key?(:query) || options.has_key?(:boundingbox) || options.has_key?(:location)
  end
  
  # The :location object provided is for the users actual location rather than the one
  # they are searching for.
  def midpoint
    options.delete(:location)
    super
  end
  
end
