class Location < ActiveRecord::Base
  attr_accessible :address, :company_id, :creator_id, :description, :email, :info, :latitude, :longitude, :name, :phone


  has_many :amenities, through: :location_amenities
  has_many :location_amenities

  has_many :organizations, through: :location_organizations
  has_many :location_organizations

  belongs_to :company
  belongs_to :creator, :class_name => "User"
  has_many :listings

  acts_as_paranoid

  # Useful for storing the full geo info for an address, like time zone
  serialize :info, Hash
end
