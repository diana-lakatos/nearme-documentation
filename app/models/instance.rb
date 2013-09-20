class Instance < ActiveRecord::Base
  attr_accessible :name, :site_name, :description, :tagline, :support_email, :contact_email,
                  :phone_number, :support_url, :blog_url, :twitter_url, :facebook_url, :meta_title,
                  :domains_attributes, :theme_attributes, :service_fee_percent

  has_one :theme, class_name: 'InstanceTheme', dependent: :destroy

  has_many :companies
  has_many :locations, :through => :companies
  has_many :listings, :through => :locations
  has_many :users
  has_many :domains, :as => :target
  has_many :pages
  has_many :email_templates

  validates_presence_of :name

  accepts_nested_attributes_for :domains, :reject_if => proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :theme, reject_if: proc { |params| params[:name].blank? }

  DEFAULT_INSTANCE_NAME = 'DesksNearMe'

  def is_desksnearme?
    self.name == DEFAULT_INSTANCE_NAME
  end

  def to_liquid
    InstanceDrop.new(self)
  end

  def default_mailer
    EmailTemplate.new(bcc: contact_email,
                      from: contact_email,
                      reply_to: contact_email)
  end

  def self.default_instance
    self.find_by_name(DEFAULT_INSTANCE_NAME)
  end
end
