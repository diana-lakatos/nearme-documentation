class ListingType < ActiveRecord::Base
  attr_accessible :name

  validates_presence_of :name, :instance_id
  validates :name, :uniqueness => true

  belongs_to :instance
  has_many :listings

end
