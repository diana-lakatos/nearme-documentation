class Workplace < ActiveRecord::Base
  acts_as_mappable :auto_geocode => true

  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :photos

  validates_presence_of :name, :address, :maximum_desks
  validates_numericality_of :maximum_desks, :only_integer => true, :greater_than => 0

  def created_by?(user)
    user && user == creator
  end

  def thumb
    images.first.thumb
  end
end
