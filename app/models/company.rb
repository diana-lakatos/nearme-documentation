class Company < ActiveRecord::Base
  attr_accessible :creator_id, :deleted_at, :description, :url, :email, :name

  belongs_to :creator, class_name: "User"
  has_many :locations

  validates_presence_of :name, :description
  validates :email, :email => true
  validates_format_of :url, :with => URI::regexp(%w(http https))

  acts_as_paranoid
end