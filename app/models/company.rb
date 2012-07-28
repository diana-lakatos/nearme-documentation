class Company < ActiveRecord::Base
  attr_accessible :creator_id, :deleted_at, :description, :email, :name

  belongs_to :creator, :class_name => "User"
  has_many :locations

  acts_as_paranoid
end
