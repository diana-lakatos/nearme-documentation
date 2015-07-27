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
  delegate :street, :address, :city, :suburb, :iso_country_code, to: :address_object

  def initialize(address_object)
    @address_object = address_object
  end
end
