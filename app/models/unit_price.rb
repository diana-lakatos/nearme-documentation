class UnitPrice < ActiveRecord::Base
  attr_accessible :price_cents, :price, :period, :listing
  belongs_to :listing

  validates_uniqueness_of :period, scope: [ :price_cents, :listing_id ]
  delegate :currency, to: :listing, :allow_nil => true
  monetize :price_cents, :allow_nil => true

end
