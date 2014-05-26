require 'test_helper'

class PaymentGatewayTest < ActiveSupport::TestCase

  should validate_presence_of(:name)
  should validate_presence_of(:settings)
  should validate_presence_of(:active_merchant_class)

  should have_many(:instance_payment_gateways)

  context "callbacks" do
    should "set method_name after creation" do
      pg = FactoryGirl.create(:payment_gateway, name: "Example")
      assert_equal pg.method_name, "example"
    end
  end

  context "methods" do
    should "#supported_countries" do
      payment_gateway = FactoryGirl.create(:paypal_payment_gateway)
      assert_equal payment_gateway.supported_countries.class, Array
    end

    should ".supported_at" do
      payment_gateways = PaymentGateway.supported_at("US")
      assert_equal payment_gateways.class, Array
      assert_equal payment_gateways.first.class, PaymentGateway
    end

    should ".countries" do
      countries = PaymentGateway.countries
      assert_equal countries.class, Array
      assert_equal countries.first.class, String
      assert_equal countries.first.length, 2
    end
  end

end
