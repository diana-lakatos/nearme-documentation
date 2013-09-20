module BillingGatewayHelper
  def mock_billing_gateway
    Stripe::Customer.stubs(:create).returns(stub(:id => '1234'))
    Stripe::Charge.stubs(:create).returns({})
    Stripe::Customer.stubs(:retrieve).returns(stub(:card= => true, :save => true))
  end
end

World(BillingGatewayHelper)
