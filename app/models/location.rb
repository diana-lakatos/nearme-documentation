class Location < ActiveRecord::Base
  
  extend FriendlyId
  friendly_id :formatted_address, use: :slugged

  attr_accessible :address, :amenity_ids, :company_id, :description, :email,
    :info, :latitude, :local_geocoding, :longitude, :currency, 
    :phone, :formatted_address, :availability_rules_attributes,
    :availability_template_id, :special_notes, :listings_attributes, :suburb,
    :city, :state, :country, :street, :address_components, :location_type_id, :photos
  attr_accessor :local_geocoding # set this to true in js

  serialize :address_components, JSON

  geocoded_by :address

  has_many :amenities, through: :location_amenities
  has_many :location_amenities

  belongs_to :company, inverse_of: :locations
  belongs_to :location_type
  delegate :creator, :to => :company

  has_many :listings,
    dependent:  :destroy,
    inverse_of: :location

  has_many :photos, :through => :listings

  has_many :availability_rules, :as => :target

  validates_presence_of :company, :description, :address, :latitude, :longitude, :location_type_id, :currency
  validates :email, email: true, allow_nil: true
  validates :currency, currency: true, allow_nil: false
  validates_length_of :description, :maximum => 250

  validates_associated :listings

  before_validation :fetch_coordinates
  before_save :assign_default_availability_rules
  before_save :parse_address_components

  acts_as_paranoid

  # Useful for storing the full geo info for an address, like time zone
  serialize :info, Hash

  # Include a set of helpers for handling availability rules and interface onto them
  include AvailabilityRule::TargetHelper
  accepts_nested_attributes_for :availability_rules, :allow_destroy => true
  accepts_nested_attributes_for :listings

  delegate :url, :to => :company

  def distance_from(other_latitude, other_longitude)
    Geocoder::Calculations.distance_between([ latitude,       longitude ],
                                            [ other_latitude, other_longitude ],
                                            units: :km)
  end

  def name
    "#{company.name} @ #{street}"
  end

  def admin?(user)
    creator == user
  end

  def currency
    super.presence || "USD"
  end

  def street
    super.presence || "Unknown"
  end

  def suburb
    super.presence || "Unknown"
  end

  def city
    super.presence || "Unknown"
  end

  def state
    super.presence || "Unknown"
  end

  def country
    super.presence || "Unknown"
  end

  def parse_address_components
    if address_components_changed?
      data_parser = Location::GoogleGeolocationDataParser.new(address_components)
      self.city = data_parser.fetch_address_component("city")
      self.suburb = data_parser.fetch_address_component("suburb")
      self.street = data_parser.fetch_address_component("street")
      self.country = data_parser.fetch_address_component("country")
      self.state = data_parser.fetch_address_component("state")
    end
  end

  def description
    read_attribute(:description) || (listings.first || NullListing.new).description
  end

  def creator=(creator)
    company.creator = creator
    company.save
  end

  def phone
    read_attribute(:phone) || creator.try(:phone)
  end

  private

  def assign_default_availability_rules
    if !availability_rules.any?
      AvailabilityRule.default_template.apply(self)
    end
  end

  def fetch_coordinates
    # If we aren't locally geocoding (cukes and people with JS off)
    if address_changed? && !(latitude_changed? || longitude_changed?)
      geocoded = Geocoder.search(address).try(:first)
      if geocoded
        self.latitude = geocoded.coordinates[0]
        self.longitude = geocoded.coordinates[1]
        self.formatted_address = geocoded.formatted_address
      end
    end
  end

end
