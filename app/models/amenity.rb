class Amenity < ActiveRecord::Base
  attr_accessible :name

  has_many :listings, through: :listing_amenities
  has_many :listing_amenities
end
