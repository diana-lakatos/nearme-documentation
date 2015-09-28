class BuySell::SaveUserAddressesService

  def initialize(user)
    @user = user
  end

  def save_addresses(billing_address, shipping_address)
    bill_address = @user.billing_address
    bill_address = Spree::Address.new unless bill_address
    bill_address.attributes = address_attributes(billing_address)
    bill_address.save!

    ship_address = @user.spree_shipping_address
    ship_address = Spree::Address.new unless ship_address
    ship_address.attributes = address_attributes(shipping_address)
    ship_address.save!

    @user.update_attributes billing_address_id: bill_address.id, shipping_address_id: ship_address.id, phone: bill_address.phone
  end

  private

  def address_attributes(address)
    address.attributes.except 'id', 'updated_at', 'created_at'
  end
end
