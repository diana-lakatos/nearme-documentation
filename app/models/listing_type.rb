class ListingType < ActiveRecord::Base
  include Metadata
  attr_accessible :name

  validates_presence_of :name, :instance_id
  validates :name, :uniqueness => { scope: :instance_id }

  belongs_to :instance
  has_many :listings

  after_commit :populate_listings_metadata!, :if => lambda { |lt| lt.metadata_relevant_attribute_changed?("name") }

  def populate_listings_metadata!
    listings.reload.each { |listing| listing.populate_listing_type_name_metadata! }
  end

end
