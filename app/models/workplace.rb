class Workplace < ActiveRecord::Base

  class SearchResults
    attr_accessor :geo_results, :search_results, :formatted_location
    def initialize
      self.geo_results = []
      self.search_results = []
    end
    def any?
      geo_results.any? || search_results.any?
    end
  end

  geocoded_by :address

  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  validates_presence_of :name, :address, :maximum_desks
  validates_numericality_of :maximum_desks, :only_integer => true, :greater_than => 0

  before_save :geocode_coordinates

  def belongs_to?(user)
    user && user == creator
  end

  # The worlds work search method.
  def self.search(query, options = {})
    return nil if query.blank?

    results = SearchResults.new

    # Try a company search first
    results.search_results = where("UPPER(name) like ?", [ "%#{query.upcase}%" ])

    # Now try a geolocation search
    geolocation = Geocoder.search(query)
    unless geolocation.nil?
      # Blindly use the first results (assume they are most accurate)
      place = geolocation['results'].first
      location = place['geometry']['location']
      results.geo_results = near([ location['lat'], location['lng'] ]).where("id NOT IN (?)", results.search_results.map(&:id)).to_a
      results.formatted_location = place['formatted_address']
    end

    results
  end

  private

    def geocode_coordinates
      fetch_coordinates if address_changed?
    end

end
