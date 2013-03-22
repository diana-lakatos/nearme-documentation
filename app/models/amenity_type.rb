class AmenityType < ActiveRecord::Base
  attr_accessible :name

  validates_presence_of :name
  validates :name, :uniqueness => true

  has_many :amenities

end
