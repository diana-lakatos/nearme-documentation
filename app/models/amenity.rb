class Amenity < ActiveRecord::Base
  attr_accessible :name, :amenity_type_id

  has_many :locations, through: :location_amenities
  has_many :location_amenities, dependent: :destroy
  
  belongs_to :amenity_type

  validates_presence_of :name

  def category
    self[:category] || 'Other'
  end

end
