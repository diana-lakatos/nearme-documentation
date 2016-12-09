# frozen_string_literal: true
class AddressDrop < BaseDrop
  # @return [Address]
  attr_reader :address_object

  # @!method street
  #   @return [String] returns the street as a string
  # @!method address
  #   @return [String] returns the address as a string
  # @!method city
  #   @return [String] returns the city as a string
  # @!method suburb
  #   @return [String] returns the suburb as a string
  # @!method iso_country_code
  #   @return [String] returns the iso_country_code
  # @!method country
  #   @return [String] returns the country as a string
  # @!method state
  #   @return [String] returns the state as a string
  # @!method postcode
  #   @return [String] returns the postcode as a string
  # @!method latitude
  #   @return [Float] returns the latitude for this address
  # @!method longitude
  #   @return [Float] returns the longitude for this address
  delegate :street, :address, :city, :suburb, :iso_country_code, :country, :state, :postcode, :latitude, :longitude, to: :address_object

  def initialize(address_object)
    @address_object = address_object
  end

  # @return [String] string containing the address in the format "city, suburb state"
  # @todo -- leave formatting for the user
  def discreet
    format('%s %s', city, postcode)
  end

  # @return [String] full address as a string
  # @todo -- leave formatting for the user
  def full
    format('%s, %s %s', address, city, postcode)
  end
end
