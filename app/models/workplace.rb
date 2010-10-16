class Workplace < ActiveRecord::Base

  class Results
    attr_accessor :results, :bounds, :location
    delegate :any?, :to => :results
  end

  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :photos
  has_many :bookings
  belongs_to :location

  validates_presence_of :name, :address, :maximum_desks, :latitude, :longitude
  validates_numericality_of :maximum_desks, :only_integer => true, :greater_than => 0

  before_validation :fetch_coordinates

  define_index do
    indexes :name
    has "RADIANS(latitude)",  :as => :latitude,  :type => :float
    has "RADIANS(longitude)", :as => :longitude, :type => :float
  end

  def created_by?(user)
    user && user == creator
  end

  def thumb
    images.first.thumb
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def self.search_with_location(location)
    results = Results.new
    results.results = []

    results.location = Geocode.search(location).try(:first)
    return results if results.location.nil?

    bounds = results.location.bounds

    if bounds
      results.bounds = bounds
      results.results = where(:latitude => bounds['southwest']['lat']..bounds['northeast']['lat'],
                              :longitude => bounds['southwest']['lng']..bounds['northeast']['lng'])
    else
      # something else
    end

    results
  end

  private

    def fetch_coordinates
      geocoded = Geocode.search(address).try(:first)
      if geocoded
        self.latitude = geocoded.latitude
        self.longitude = geocoded.longitude
      end
    end

end
