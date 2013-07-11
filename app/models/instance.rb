class Instance < ActiveRecord::Base
  attr_accessible :name

  has_many :companies
  has_many :locations, :through => :companies
  has_many :listings, :through => :locations
  has_many :users
  has_many :domains
  belongs_to :partner

  delegate :service_fee_percent, to: :partner,  allow_nil: true

  DEFAULT_INSTANCE_NAME = 'DesksNearMe'

  def is_desksnearme?
    self.name == DEFAULT_INSTANCE_NAME
  end

  def self.default_instance
    @default_instance ||= self.find_by_name(DEFAULT_INSTANCE_NAME)
  end

  def self.find_for_request(request)
    host = request.host.gsub(/^www\./, "")
    joins(:domains).where('domains.name LIKE ?', host).first
  end

end
