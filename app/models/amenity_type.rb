class AmenityType < ActiveRecord::Base
  attr_accessible :name, :amenities_attributes, :instance_id

  validates_presence_of :name
  validates :name, :uniqueness => { scope: :instance_id }

  belongs_to :instance
  has_many :amenities, order: 'amenities.name ASC'
  has_many :locations,
    :through => :amenities

  accepts_nested_attributes_for :amenities, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }

  def self.build_with_amenity
    amenity_type = AmenityType.new
    amenity_type.amenities.build

    amenity_type
  end

end
