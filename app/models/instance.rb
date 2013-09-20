class Instance < ActiveRecord::Base
  attr_accessible :name, :domains_attributes, :theme_attributes, :service_fee_percent, :bookable_noun

  has_one :theme, :as => :owner, dependent: :destroy

  has_many :companies
  has_many :locations, :through => :companies
  has_many :listings, :through => :locations
  has_many :users
  has_many :domains, :as => :target
  has_many :pages

  validates_presence_of :name

  accepts_nested_attributes_for :domains, :reject_if => proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :theme, reject_if: proc { |params| params[:name].blank? }

  DEFAULT_INSTANCE_NAME = 'DesksNearMe'

  def is_desksnearme?
    self.name == DEFAULT_INSTANCE_NAME
  end

  def self.default_instance
    @default_instance ||= self.find_by_name(DEFAULT_INSTANCE_NAME)
  end

  def white_label_enabled?
    true
  end

end
