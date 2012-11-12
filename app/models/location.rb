class Location < ActiveRecord::Base
  attr_accessible :address, :amenity_ids, :company_id, :creator_id, :description, :email, :require_organization_membership,
    :info, :latitude, :local_geocoding, :longitude, :organization_ids, :name, :currency, :phone, :formatted_address, :availability_rules_attributes, :availability_template_id,
    :special_notes, :listings_attributes
  attr_accessor :local_geocoding # set this to true in js
  geocoded_by :address

  has_many :amenities, through: :location_amenities
  has_many :location_amenities

  has_many :organizations, through: :location_organizations
  has_many :location_organizations

  belongs_to :company
  belongs_to :creator, class_name: "User"
  has_many :listings
  has_many :photos, :through => :listings

  has_many :availability_rules, :as => :target

  validates_presence_of :company_id, :name, :description, :address, :latitude, :longitude
  validates :email, email: true, allow_nil: true
  validates :currency, currency: true, allow_nil: true

  before_validation :fetch_coordinates
  before_validation :set_default_creator
  before_save :assign_default_availability_rules

  acts_as_paranoid

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

  def required_organizations
    require_organization_membership? ? organizations : []
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

    def set_default_creator
      self.creator ||= company.try(:creator)
    end

end
