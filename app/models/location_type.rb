class LocationType < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  # attr_accessible :name

  validates_presence_of :name
  validates :name, uniqueness: { scope: :instance_id }

  belongs_to :instance
  has_many :locations
  has_many :listings, through: :locations, class_name: 'Transactable'

  def to_s
    name
  end
end
