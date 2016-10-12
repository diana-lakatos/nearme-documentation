class AmenityType < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  # attr_accessible :name, :amenities_attributes

  validates_presence_of :name
  validates :name, uniqueness: { scope: :instance_id }

  belongs_to :instance
  has_many :amenities, -> { order 'amenities.name ASC' }, dependent: :destroy
  has_many :locations, through: :amenities
  has_many :listings, through: :amenities, class_name: 'Transactable'

  accepts_nested_attributes_for :amenities, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }

  def self.build_with_amenity
    amenity_type = AmenityType.new
    amenity_type.amenities.build

    amenity_type
  end
end
