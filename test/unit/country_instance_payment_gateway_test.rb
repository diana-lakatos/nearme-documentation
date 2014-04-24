require 'test_helper'

class CountryInstancePaymentGatewayTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:instance_payment_gateway)

  setup do
    @stripe = FactoryGirl.create(:stripe_instance_payment_gateway)
    @country_instance_payment_gateway = FactoryGirl.create(:country_instance_payment_gateway, instance_payment_gateway_id: @stripe.id)
  end

  context "methods" do
    should "#name" do
      assert_equal @country_instance_payment_gateway.name, @stripe.payment_gateway.name
    end

    should "#country" do
      assert_equal "US", @country_instance_payment_gateway.country_alpha2_code
      assert_equal "United States", @country_instance_payment_gateway.country.name
    end
  end
end
