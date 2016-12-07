module Shippings
  class ShippingAddressBuilder
    def self.build(order, user)
      shipping_address = new(order, user).shipping_address

      # extract to validator factory
      if order.shipping_provider && order.shipping_provider.shipping_provider_name == 'sendle'
        shipping_address.address.add_validator Deliveries::Sendle::Validations::Address.new
      end

      shipping_address
    end

    def initialize(order, user)
      @order = order
      @user = user
    end

    def shipping_address
      return @order.shipping_address if @order.shipping_address

      @order.build_shipping_address firstname: source.firstname,
                                    lastname: source.lastname,
                                    phone: source.phone,
                                    email: source.email,
                                    address: source.address.dup,
                                    instance_id: @order.instance_id
    end

    private

    def source
      @source ||= @user.shipping_addresses.last || address_from_user_data
    end

    def address_from_user_data
      OpenStruct.new(email: @user.email,
                     firstname: @user.first_name,
                     lastname: @user.last_name,
                     phone: @user.full_mobile_number,
                     instance_id: @order.instance_id,
                     address: default_address)
    end

    def default_address
      Address.new
    end
  end
end
