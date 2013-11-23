class LocationType < ActiveRecord::Base
  attr_accessible :name

  validates_presence_of :name, :instance_id
  validates :name, :uniqueness => { scope: :instance_id }

  belongs_to :instance
  has_many :locations

end
