class AddressDrop < BaseDrop
  attr_reader :address_object

  # street
  #   returns the street as a string
  # address
  #   returns the address as a string
  # city
  #   returns the city as a string
  # suburb
  #   returns the suburb as a string
  # country
  #   returns the country as a string
  # state
  #   returns the state as a string
  # postcode
  #   returns the postcode as a string
  # latitude
  #   returns the latitude for this address
  # longitude
  #   returns the longitude for this address
  delegate :street, :address, :city, :suburb, :iso_country_code, :country, :state, :postcode, :latitude, :longitude, to: :address_object

  def initialize(address_object)
    @address_object = address_object
  end

  def discreet
    format('%s, %s %s', city, suburb, state)
  end

  def full
    address
  end
end
