class Company < ActiveRecord::Base
  attr_accessible :creator_id, :deleted_at, :description, :url, :email, :name

  belongs_to :creator, class_name: "User"
  has_many :locations

  validates_presence_of :name, :description
  validates :email, email: true, allow_blank: true
  validates_format_of :url, with: URI::regexp(%w(http https)), allow_blank: true

  acts_as_paranoid
end