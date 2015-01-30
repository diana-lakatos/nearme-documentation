class AddressDrop < BaseDrop

  attr_reader :address_object
  delegate :street, :address, :city, :suburb, to: :address_object

  def initialize(address_object)
    @address_object = address_object
  end
end
