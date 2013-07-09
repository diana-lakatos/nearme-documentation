class Instance < ActiveRecord::Base
  attr_accessible :name

  has_many :companies
  has_many :locations, :through => :companies
  has_many :listings, :through => :locations
  has_many :users
  belongs_to :partner

  delegate :service_fee_percent, to: :partner,  allow_nil: true

  def is_desksnearme?
    self.name == 'DesksNearMe'
  end
end
