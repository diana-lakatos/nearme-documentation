class Location < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end
  has_paper_trail
  acts_as_paranoid
  scoped_to_platform_context

  has_metadata :accessors => [:photos_metadata]
  notify_associations_about_column_update([:reservations, :listings], :administrator_id)
  notify_associations_about_column_update([:reservation_charges, :reservations, :listings], :company_id)
  inherits_columns_from_association([:creator_id, :listings_public], :company)

  include Impressionable
  attr_accessible :address, :address2, :amenity_ids, :company_id, :description, :email,
    :info, :latitude, :local_geocoding, :longitude, :currency,
    :formatted_address, :availability_rules_attributes, :postcode, :phone,
    :availability_template_id, :special_notes, :listings_attributes, :suburb,
    :city, :state, :country, :street, :address_components, :location_type_id, :photos,
    :administrator_id, :name
  attr_accessor :local_geocoding # set this to true in js
  attr_accessor :name_and_description_required
  attr_accessor :searched_locations, :search_rank

  liquid_methods :name

  serialize :address_components, JSON

  geocoded_by :address

  has_many :amenity_holders, as: :holder, dependent: :destroy
  has_many :amenities, through: :amenity_holders

  belongs_to :company, inverse_of: :locations
  belongs_to :location_type
  belongs_to :administrator, class_name: "User", :inverse_of => :administered_locations
  belongs_to :instance
  belongs_to :creator, class_name: "User"
  delegate :company_users, :to => :company, :allow_nil => true

  delegate :url, :to => :company
  delegate :service_fee_guest_percent, :service_fee_host_percent, to: :company, allow_nil: true
  delegate :phone, :to => :creator, :allow_nil => true

  has_many :listings,
    dependent:  :destroy,
    inverse_of: :location,
    class_name: 'Transactable'

  has_many :reservations, :through => :listings
  has_many :reservation_charges, :through => :reservations
  has_many :photos, :through => :listings

  has_many :availability_rules, :order => 'day ASC', :as => :target

  has_many :impressions, :as => :impressionable, :dependent => :destroy
  has_many :reviews, :through => :listings

  validates_presence_of :company, :address, :latitude, :longitude, :location_type_id, :currency
  validates_presence_of :description, :if => :name_and_description_required
  validates_presence_of :name, :if => :name_and_description_required
  validates :email, email: true, allow_nil: true
  validates :currency, currency: true, allow_nil: false
  validates_length_of :description, :maximum => 250, :if => :name_and_description_required
  validates_length_of :name, :maximum => 50, :if => :name_and_description_required

  before_validation :fetch_coordinates
  before_validation :parse_address_components
  before_save :assign_default_availability_rules

  extend FriendlyId
  friendly_id :urlify, use: [:slugged, :history]

  scope :filtered_by_location_types_ids,  lambda { |location_types_ids| where('locations.location_type_id IN (?)', location_types_ids) }
  scope :filtered_by_industries_ids,  lambda { |industry_ids| joins(:company => :company_industries).where('company_industries.industry_id IN (?)', industry_ids) }
  scope :none, where(:id => nil)
  scope :with_searchable_listings, where(%{ (select count(*) from "listings" where location_id = locations.id and listings.draft IS NULL and enabled = 't' and listings.deleted_at is null) > 0 })

  # Useful for storing the full geo info for an address, like time zone
  serialize :info, Hash

  # Include a set of helpers for handling availability rules and interface onto them
  include AvailabilityRule::TargetHelper
  accepts_nested_attributes_for :availability_rules, :allow_destroy => true
  accepts_nested_attributes_for :listings


  def distance_from(other_latitude, other_longitude)
    Geocoder::Calculations.distance_between([ latitude,       longitude ],
                                            [ other_latitude, other_longitude ],
                                            units: :km)
  end

  def assign_default_availability_rules
    if availability_rules.reject(&:marked_for_destruction?).empty?
      AvailabilityRule.default_template.apply(self)
    end
  end

  def name
    read_attribute(:name).presence || [company.name, street].compact.join(" @ ")
  end

  def admin?(user)
    creator == user
  end

  def currency
    super.presence || "USD"
  end

  def street
    super.presence || address.try{|a| a.split(",")[0] }
  end

  def suburb
    super.presence
  end

  def city
    super.presence
  end

  def state
    super.presence
  end

  def country
    super.presence
  end

  def postcode
    super.presence
  end

  def address
    read_attribute(:formatted_address).presence || read_attribute(:address)
  end

  def state_code
    @state_code ||= Location::GoogleGeolocationDataParser.new(address_components).fetch_address_component("state", :short)
  end

  def parse_address_components
    if address_components_changed?
      data_parser = Location::GoogleGeolocationDataParser.new(address_components)
      self.city = data_parser.fetch_address_component("city")
      self.suburb = data_parser.fetch_address_component("suburb")
      self.street = data_parser.fetch_address_component("street")
      self.country = data_parser.fetch_address_component("country")
      self.state = data_parser.fetch_address_component("state")
      self.postcode = data_parser.fetch_address_component("postcode")
    end
  end

  def description
    read_attribute(:description).presence || listings.first.try(:description).presence || ""
  end

  def administrator
    super.presence || creator
  end

  def creator=(creator)
    company.creator = creator
    company.save
  end

  def email
    read_attribute(:email).presence || creator.try(:email)
  end

  def phone=(phone)
    creator.phone = phone if creator.phone.blank? if creator
  end

  def to_liquid
    LocationDrop.new(self)
  end

  def timezone
    NearestTimeZone.to(latitude, longitude)
  end

  def local_time
    Time.now.in_time_zone(timezone)
  end

  def self.xml_attributes
    [:address, :address2, :formatted_address, :city, :street, :state, :postcode, :email, :phone, :description, :special_notes, :currency]
  end

  def lowest_price(available_price_types = [])
    (searched_locations || listings.searchable).map{|l| l.lowest_price_with_type(available_price_types)}.compact.sort{|a, b| a[0].to_f <=> b[0].to_f}.first
  end

  private

  def fetch_coordinates
    # If we aren't locally geocoding (cukes and people with JS off)
    if (address_changed? && !(latitude_changed? || longitude_changed?))
      populator = Location::AddressComponentsPopulator.new(self)
      geocoded = populator.geocode
      if geocoded
        self.latitude = geocoded.coordinates[0]
        self.longitude = geocoded.coordinates[1]
        self.formatted_address = geocoded.formatted_address
        self.address_components = populator.wrapped_address_components
      else
        # do not allow to save when cannot geolocate
        self.latitude = nil
        self.longitude = nil
      end
    end
  end

  def urlify
    # given company name is My Company and city is San Francisco, generated "my+company-san+francisco"
    if company.try(:name).present? && city.present? && company.name.strip.downcase.include?(city.strip.downcase)
      company.name
    else
      "#{company.try(:name).try(:strip)} #{city}".strip
    end
  end
end
