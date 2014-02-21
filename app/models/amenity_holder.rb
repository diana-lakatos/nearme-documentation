class AmenityHolder < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :amenity
  belongs_to :holder, polymorphic: true

end
