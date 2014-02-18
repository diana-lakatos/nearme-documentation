class ListingType < ActiveRecord::Base
  has_metadata :without_db_column => true
  attr_accessible :name

  validates_presence_of :name, :instance_id
  validates :name, :uniqueness => { scope: :instance_id }

  belongs_to :instance
  has_many :listings

end
