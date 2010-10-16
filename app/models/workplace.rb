class Workplace < ActiveRecord::Base

  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :photos
  has_many :bookings
  belongs_to :location

  validates_presence_of :name, :address, :maximum_desks, :location_id
  validates_numericality_of :maximum_desks, :only_integer => true, :greater_than => 0

  before_validation :find_location

  define_index do
    indexes :name
  end

  def created_by?(user)
    user && user == creator
  end

  def thumb
    images.first.thumb
  end

  private

    def find_location
      self.location = Location.find_or_create_by_geocode(address) if address
    rescue Location::MissingLocation
      errors.add(:location, :missing)
    end

end

