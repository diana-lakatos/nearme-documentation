require 'test_helper'

class CountryPaymentGatewayTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:payment_gateway)

  setup do
    @stripe = FactoryGirl.create(:stripe_payment_gateway)
    @country_payment_gateway = FactoryGirl.create(:country_payment_gateway, payment_gateway: @stripe, country_alpha2_code: 'US')
  end

  context "methods" do
    should "#name" do
      assert_equal @country_payment_gateway.name, @stripe.name
    end

    should "#country" do
      assert_equal "US", @country_payment_gateway.country_alpha2_code
      assert_equal "United States", @country_payment_gateway.country.name
    end
  end
end
