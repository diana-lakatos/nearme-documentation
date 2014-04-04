class Amenity < ActiveRecord::Base
  attr_accessible :name, :amenity_type_id

  belongs_to :amenity_type
  has_many :amenity_holders, dependent: :destroy
  has_many :listings, through: :amenity_holders, source: :holder, source_type: 'Transactable'
  has_many :locations, through: :amenity_holders, source: :holder, source_type: 'Location'

  validates_presence_of :name

  def category
    self[:category] || 'Other'
  end

end
