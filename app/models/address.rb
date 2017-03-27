class Address < ActiveRecord::Base
  include Validatable
  has_paper_trail
  acts_as_paranoid
  scoped_to_platform_context

  # attr_accessible :address, :address2, :latitude, :local_geocoding, :longitude, :suburb,
  #   :formatted_address, :postcode, :city, :state, :country, :street, :address_components

  attr_accessor :local_geocoding # set this to true in js
  attr_accessor :should_check_address
  attr_accessor :country_id, :state_id

  serialize :address_components, JSON
  geocoded_by :address

  belongs_to :instance
  belongs_to :entity, -> { with_deleted }, polymorphic: true, touch: true

  validates_presence_of :address, unless: :accurate_address_required
  validate :check_address, if: :accurate_address_required
  validates_presence_of :latitude, :longitude, if: ->(l) { !l.raw_address? }

  before_validation :update_address, if: ->(l) { !l.raw_address? }
  before_validation :parse_address_components, if: ->(l) { !l.raw_address? }

  # not sure if this is buggy
  # before_validation :clear_fields, if: ->(l) { l.raw_address? }

  scope :bounding_box, lambda  { |box|
    where('addresses.latitude > ? AND addresses.latitude < ?', box[:bottom_left][:lat], box[:top_right][:lat])
      .where('addresses.longitude > ? AND addresses.longitude < ?', box[:bottom_left][:lon], box[:top_right][:lon])
  }

  after_save do
    if entity.is_a?(Location)
      entity.listings.each do |l|
        ElasticIndexerJob.perform(:update, l.class.to_s, l.id)
      end
    end
  end

  def clear_fields
    [:street, :formatted_address, :suburb, :city, :country, :state, :postcode, :address_components, :latitude, :longitude, :iso_country_code, :street_number].each do |field|
      send("#{field}=", nil)
    end
  end

  def check_address
    unless postcode && city && state && street
      errors.add(:address, I18n.t('errors.messages.inaccurate_address'))
    end
  end

  def self.order_by_distance_sql(latitude, longitude)
    distance_sql(latitude, longitude, order: 'distance')
  end

  def distance_from(other_latitude, other_longitude)
    Geocoder::Calculations.distance_between([latitude, longitude], [other_latitude, other_longitude], units: :km)
  end

  def street
    super.presence || address.try { |a| a.split(',')[0] }
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

  def country_object
    Country.find_by_iso(iso_country_code)
  end

  def state_object
    if country_object.present?
      country_object.states.where(abbr: state_code).first
    end
  end

  def postcode
    super.presence
  end

  def address
    self[:formatted_address].presence || self[:address]
  end

  def state_code
    @state_code ||= Address::GoogleGeolocationDataParser.new(address_components).fetch_address_component('state', :short)
  end

  def country_id=(attr_id)
    @country_id = attr_id
    self.country = Country.find_by(id: attr_id).try(:name)
  end

  def state_id=(attr_id)
    @state_id = attr_id
    self.state = State.find_by(id: attr_id).try(:name)
  end

  def country_id
    return unless country
    Country.find_by(name: country).try(:id)
  end

  def state_id
    return unless state
    return unless country

    State.find_by(name: state, country_id: country_id).try(:id)
  end

  def parse_address_components
    parse_address_components! if address_components_changed?
  end

  def parse_address_components!
    data_parser = Address::GoogleGeolocationDataParser.new(address_components)
    self.city = data_parser.fetch_address_component('city')
    self.suburb = data_parser.fetch_address_component('suburb')
    self.street = data_parser.fetch_address_component('street')
    self.country = data_parser.fetch_address_component('country')
    self.iso_country_code = data_parser.fetch_address_component('country', :short)
    self.state = data_parser.fetch_address_component('state')
    self.postcode = data_parser.fetch_address_component('postcode')
    self.street_number = data_parser.fetch_address_component('street_number')
  end

  def to_s
    address
  end

  def self.xml_attributes
    [:address, :address2, :formatted_address, :city, :street, :state, :postcode]
  end

  def self.csv_fields
    { address: 'Address', city: 'City', street: 'Street', suburb: 'Suburb', state: 'State', postcode: 'Postcode' }
  end

  def update_address
    if should_fetch_coordinates?
      fetch_coordinates!
    elsif should_fetch_address?
      fetch_address!
    end
    nil
  end

  def fetch_coordinates!
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
    geocoded
  end

  def fetch_address!
    populator = Address::AddressComponentsPopulator.new(self)
    geocoded = populator.reverse_geocode
    if geocoded
      self.address = geocoded.formatted_address
      self.formatted_address = geocoded.formatted_address
      self.address_components = populator.wrapped_address_components
    else
      # do not allow to save when cannot geolocate
      self.address = nil
    end
    geocoded
  end

  def should_fetch_coordinates?
    address_changed? && (!(latitude_changed? || longitude_changed?) || (latitude.blank? && longitude.blank?))
  end

  def should_fetch_address?
    (!address_changed? && (latitude_changed? || longitude_changed?))
  end

  def to_liquid
    @address_drop ||= AddressDrop.new(self)
  end

  def self.sanitize_bounding_box(bounding_box)
    [bounding_box[:bottom_left].values, bounding_box[:top_right].values]
  end

  def jsonapi_serializer_class_name
    'AddressJsonSerializer'
  end

  private

  def accurate_address_required
    should_check_address == 'true' && !raw_address?
  end
end
