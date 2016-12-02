class Listing::Search::Params::ApiParams < Listing::Search::Params
  def initialize(options, transactable_type = nil)
    super
    fail Listing::Search::SearchTypeNotSupported unless valid_search_method?
  end

  def valid_search_method?
    options.key?(:query) || options.key?(:boundingbox) || options.key?(:location)
  end

  # The :location object provided is for the users actual location rather than the one
  # they are searching for.
  def midpoint
    @midpoint ||= begin
      if @options[:location].present?
        [@options[:location][:lat], @options[:location][:lon]]
      elsif bounding_box.present?
        ::Geocoder::Calculations.geographic_center([bounding_box[:top_right].values, bounding_box[:bottom_left].values])
      end
    end
  end
end
