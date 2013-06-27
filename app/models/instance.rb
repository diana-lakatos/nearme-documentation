class Instance < ActiveRecord::Base
  attr_accessible :name

  has_many :companies
  has_many :locations, :through => :companies
  has_many :listings, :through => :locations
  has_many :users
  belongs_to :partner

  def is_desksnearme?
    self.name == 'DesksNearMe'
  end
end
