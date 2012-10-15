class ListingUnitPrice < ActiveRecord::Base
  attr_accessible :price_cents, :price, :period, :listing
  belongs_to :listing

  monetize :price_cents, :allow_nil => true
end
