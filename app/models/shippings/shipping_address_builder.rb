module Shippings
  class ShippingAddressBuilder
    def self.build(order, user)
      new(order, user).shipping_address
    end

    def initialize(order, user)
      @order = order
      @user = user
    end

    def shipping_address
      return @order.shipping_address if @order.shipping_address

      @order.build_shipping_address firstname: firstname,
                                    lastname: lastname,
                                    phone: phone,
                                    email: email,
                                    address: google_address,
                                    instance_id: @order.instance_id
    end

    private

    def email
      user_address.email || @user.email
    end

    def firstname
      user_address.firstname || @user.first_name
    end

    def lastname
      user_address.lastname || @user.last_name
    end

    def phone
      user_address.phone || @user.full_mobile_number
    end

    def google_address
      user_google_address || default_address
    end

    def default_address
      Address.new
    end

    def user_google_address
      user_address.address && user_address.address.dup.tap do |add|
        add.add_validator Deliveries::Sendle::Validations::Address.new
      end
    end

    def user_address
      @user_address ||= @user.shipping_addresses.last || @user.shipping_addresses.build
    end
  end
end
