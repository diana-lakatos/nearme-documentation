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
  has_many :photos

  validates_presence_of :name, :address, :maximum_desks
  validates_numericality_of :maximum_desks, :only_integer => true, :greater_than => 0

  before_save :geocode_coordinates

  def created_by?(user)
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

      geo_results = near([ location['lat'], location['lng'] ], 20)

      # Filter out those found in the name search
      geo_results = geo_results.where("id NOT IN (?)", results.search_results.map(&:id)) if results.search_results.any?

      results.geo_results = geo_results.to_a
      results.formatted_location = place['formatted_address']
    end

    results
  end

  def thumb
    images.first.thumb
  end

  private

    def geocode_coordinates
      fetch_coordinates if address_changed?
    end

end
