class Amenity < ActiveRecord::Base
  attr_accessible :name

  has_many :listings, through: :listing_amenities
  has_many :listing_amenities
  
  belongs_to :amenity_type

  validates_presence_of :name

  def category
    self[:category] || 'Other'
  end

end
