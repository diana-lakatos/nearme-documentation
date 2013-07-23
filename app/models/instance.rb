class Instance < ActiveRecord::Base
  attr_accessible :name, :site_name, :description, :tagline, :support_email, :contact_email,
                  :phone_number, :support_url, :blog_url, :twitter_url, :facebook_url,
                  :domains_attributes

  has_many :companies
  has_many :locations, :through => :companies
  has_many :listings, :through => :locations
  has_many :users
  has_many :domains
  belongs_to :partner

  validates_presence_of :name

  accepts_nested_attributes_for :domains, :reject_if => proc { |params| params[:name].blank? }
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
