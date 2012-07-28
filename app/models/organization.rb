class Organization < ActiveRecord::Base
  mount_uploader :logo, AvatarUploader
  attr_accessible :name

  has_many :listings, through: :listing_organizations
  has_many :listing_organizations
end
