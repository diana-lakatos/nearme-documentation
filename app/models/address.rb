class Address < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  scoped_to_platform_context

  # attr_accessible :address, :address2, :latitude, :local_geocoding, :longitude, :suburb,
  #   :formatted_address, :postcode, :city, :state, :country, :street, :address_components

  attr_accessor :local_geocoding # set this to true in js

  serialize :address_components, JSON
  geocoded_by :address

  belongs_to :instance
  belongs_to :entity, polymorphic: true

  validates_presence_of :address, :latitude, :longitude
  before_validation :fetch_coordinates
  before_validation :parse_address_components
  def self.order_by_distance_sql(latitude, longitude)
    distance_sql(latitude, longitude, order: "distance")
  end

  def distance_from(other_latitude, other_longitude)
    Geocoder::Calculations.distance_between([ latitude,       longitude ],
                                            [ other_latitude, other_longitude ],
                                            units: :km)
  end

  def street
    super.presence || address.try { |a| a.split(",")[0] }
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
    @state_code ||= Address::GoogleGeolocationDataParser.new(address_components).fetch_address_component("state", :short)
  end

  def parse_address_components
    if address_components_changed?
      data_parser = Address::GoogleGeolocationDataParser.new(address_components)
      self.city = data_parser.fetch_address_component("city")
      self.suburb = data_parser.fetch_address_component("suburb")
      self.street = data_parser.fetch_address_component("street")
      self.country = data_parser.fetch_address_component("country")
      self.state = data_parser.fetch_address_component("state")
      self.postcode = data_parser.fetch_address_component("postcode")
    end
  end

  def to_s
    self.address
  end

  private

  def fetch_coordinates
    # If we aren't locally geocoding (cukes and people with JS off)
    if (address_changed? && !(latitude_changed? || longitude_changed?))
      populator = Address::AddressComponentsPopulator.new(self)
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

end

