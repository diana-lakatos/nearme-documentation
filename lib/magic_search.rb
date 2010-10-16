module MagicSearch

  class SearchResults
    attr_accessor :geo_results, :search_results, :location, :location_alternatives
    def initialize
      self.geo_results = []
      self.search_results = []
      self.location_alternatives = []
    end
    def any?
      geo_results.any? || search_results.any?
    end
  end

  def self.search(query)
    return nil if query.blank?

    results = SearchResults.new

    # Do a name search
    results.search_results = Workplace.search(query)

    # Geolocation search
    geolocations = Geocode.search(query)
    unless geolocations.nil?
      place = geolocations.shift
      results.location_alternatives = geolocations
      results.location = place.name

      results.geo_results = Workplace.joins(:location).where(:locations => place.parts)
    end

    results
  end

end
