class Instance < ActiveRecord::Base
  attr_accessible :name, :domains_attributes, :theme_attributes, :location_types_attributes, :listing_types_attributes,
                  :service_fee_guest_percent, :service_fee_host_percent, :bookable_noun, :lessor, :lessee,
                  :listing_amenity_types_attributes, :location_amenity_types_attributes, :skip_company, :pricing_options

  has_one :theme, :as => :owner, dependent: :destroy

  has_many :companies
  has_many :locations, :through => :companies
  has_many :locations_impressions,
           :through => :companies
  has_many :location_types
  has_many :listing_amenity_types
  has_many :location_amenity_types
  has_many :reservations,
           :through => :companies
  has_many :listings, :through => :locations
  has_many :listing_types
  has_many :domains, :as => :target
  has_many :partners
  has_many :instance_admins
  has_many :instance_admin_roles
  has_many :reservations, :as => :platform_context_detail, :dependent => :destroy

  serialize :pricing_options, Hash

  validates_presence_of :name
  validates :pricing_options, presence: { message: :must_be_selected }

  after_initialize :set_all_pricing_options

  accepts_nested_attributes_for :domains, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :theme, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :location_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :listing_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :location_amenity_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :listing_amenity_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }

  PRICING_OPTIONS = %w(free hourly daily weekly monthly)

  def is_desksnearme?
    self.default_instance?
  end

  def white_label_enabled?
    true
  end

  def self.default_instance
    self.find_by_default_instance(true)
  end

  def lessor
    super.presence || "host"
  end

  def lessee
    super.presence || "guest"
  end

  def to_liquid
    InstanceDrop.new(self)
  end

  private

  def set_all_pricing_options
    return if (!new_record? || !self.pricing_options.empty?)
    self.pricing_options = Hash[Instance::PRICING_OPTIONS.map{|po| [po, '1']}]
  end
end
