class Instance < ActiveRecord::Base
  attr_accessible :name, :domains_attributes, :theme_attributes, :location_types_attributes, :listing_types_attributes,
                  :service_fee_percent, :bookable_noun, :lessor, :lessee, :amenity_types_attributes

  has_one :theme, :as => :owner, dependent: :destroy

  has_many :companies
  has_many :locations, :through => :companies
  has_many :locations_impressions,
           :through => :companies
  has_many :location_types
  has_many :amenity_types
  has_many :amenities,
           :through => :amenity_types
  has_many :reservations,
           :through => :companies
  has_many :reservation_charges,
           :through => :companies
  has_many :listings, :through => :locations
  has_many :listing_types
  has_many :domains, :as => :target
  has_many :partners
  has_many :instance_admins
  has_many :instance_admin_roles

  validates_presence_of :name

  accepts_nested_attributes_for :domains, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :theme, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :location_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :listing_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :amenity_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }

  DEFAULT_INSTANCE_NAME = 'DesksNearMe'

  def is_desksnearme?
    self.name == DEFAULT_INSTANCE_NAME
  end

  def white_label_enabled?
    true
  end

  def self.default_instance
    self.find_by_name(DEFAULT_INSTANCE_NAME)
  end
end
