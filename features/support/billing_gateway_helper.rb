module BillingGatewayHelper
  def mock_billing_gateway
    Stripe::Customer.expects(:create).returns(stub(:id => '1234'))
    Stripe::Charge.expects(:create).returns({})
    Stripe::Customer.expects(:retrieve).returns(stub(:card= => true, :save => true))
  end
end

World(BillingGatewayHelper)