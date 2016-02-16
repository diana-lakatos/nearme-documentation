class AmenityHolder < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :amenity, touch: true
  belongs_to :holder, polymorphic: true, touch: true

end
