class Workplace < ActiveRecord::Base

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
    group_by "latitude", "longitude"
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

  def self.search_with_location(query)
    geocoded = Geocoder.search(query).try(:[], 'results').try(:first)
    return [ [], nil ] if geocoded.nil?

    location = { :name => geocoded['formatted_address'], 
                 :lat => geocoded['geometry']['location']['lat'],
                 :lng => geocoded['geometry']['location']['lng'] }

    [ search(:geo => [ Geocoder.to_radians(location[:lat]), Geocoder.to_radians(location[:lng]) ], 
             :with => { "@geodist" => (0.0)..(30_000.0) }, :order => "@geodist ASC, @relevance DESC") , location ]
  end

  private

    def fetch_coordinates
      geocoded = Geocoder.search(address).try(:[], 'results').try(:first)
      if geocoded
        self.latitude = geocoded['geometry']['location']['lat']
        self.longitude = geocoded['geometry']['location']['lng']
      end
    end

end
