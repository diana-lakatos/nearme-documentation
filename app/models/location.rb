class Location < ActiveRecord::Base
  attr_accessible :address, :amenity_ids, :company_id, :description, :email,
    :info, :latitude, :local_geocoding, :longitude, :name,
    :currency, :phone, :formatted_address, :availability_rules_attributes,
    :availability_template_id,
    :special_notes, :listings_attributes
  attr_accessor :local_geocoding # set this to true in js
  attr_accessor :address_components_hash # data to create address_component_names and _types will be stored here

  geocoded_by :address

  has_many :amenities, through: :location_amenities
  has_many :location_amenities

  belongs_to :company
  delegate :creator, :to => :company

  has_many :listings,
           :dependent => :destroy

  has_many :photos, :through => :listings
  has_many :feeds, :through => :listings

  has_many :availability_rules, :as => :target

  has_many :address_component_names, :dependent => :destroy

  validates_presence_of :company_id, :name, :description, :address, :latitude, :longitude
  validates :email, email: true, allow_nil: true
  validates :currency, currency: true, allow_nil: true
  validates_length_of :description, :maximum => 250

  before_validation :fetch_coordinates
  before_save :assign_default_availability_rules

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

  def organizations
    []
  end

  def admin?(user)
    creator == user
  end

  def build_address_components_if_necessary
    if formatted_address_changed?
      unless address_components_hash.empty? 
        cleanup_address_components
        build_address_components
        true
      else
        false
      end
    else
      false
    end
  end

  def cleanup_address_components
    address_component_names.destroy_all
  end

  def build_address_components
    cached_types_hash = {}
    parsed_address_components_hash = AddressComponent::Parser.parse_geocoder_address_component_hash(address_components_hash)
    parsed_address_components_hash.each do |index, address_component|
      address_component_name = AddressComponentName.new({:short_name => address_component["short_name"], :long_name => address_component["long_name"]})
      address_component_name.location = self
      address_component_name.save!
      address_component["types"].each do |type|
        if cached_types_hash[type]
          address_component_name.address_component_types << cached_types_hash[type]
        else
          address_component_type = AddressComponentType.find_or_create_by_name(type)
          address_component_name.address_component_types << address_component_type
        end
      end
    end
  end

  def description
    read_attribute(:description) || (listings.first || NullListing.new).description
  end

  def creator=(creator)
    company.creator = creator
    company.save
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
