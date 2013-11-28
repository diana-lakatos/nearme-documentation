class AmenityHolder < ActiveRecord::Base
  belongs_to :amenity
  belongs_to :holder, polymorphic: true
end
