# frozen_string_literal: true
class AddressDrop < BaseDrop
  # @return [Address]
  attr_reader :address_object

  # @!method street
  #   returns the street as a string
  #   @return (see Address#street)
  # @!method address
  #   returns the address as a string
  #   @return (see Address#address)
  # @!method city
  #   returns the city as a string
  #   @return (see Address#city)
  # @!method suburb
  #   returns the suburb as a string
  #   @return (see Address#suburb)
  # @!method iso_country_code
  #   returns the iso_country_code
  #   @return (see Address#iso_country_code)
  # @!method country
  #   returns the country as a string
  #   @return (see Address#country)
  # @!method state
  #   returns the state as a string
  #   @return (see Address#state)
  # @!method postcode
  #   returns the postcode as a string
  #   @return (see Address#postcode)
  # @!method latitude
  #   returns the latitude for this address
  #   @return (see Address#latitude)
  # @!method longitude
  #   returns the longitude for this address
  #   @return (see Address#longitude)
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
