class ListingAmenity < ActiveRecord::Base
  belongs_to :listing, class_name: 'Transactable'
  belongs_to :amenity
end
