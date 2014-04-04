class ListingType < ActiveRecord::Base
  has_metadata :without_db_column => true
  auto_set_platform_context
  scoped_to_platform_context
  attr_accessible :name

  validates_presence_of :name
  validates :name, :uniqueness => { scope: :instance_id }

  belongs_to :instance
  has_many :listings, class_name: 'Transactable'

end
