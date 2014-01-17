module BillingGatewayHelper
  def mock_billing_gateway
    Stripe::Customer.stubs(:create).returns(stub(:id => '1234')).at_least(0)
    Stripe::Charge.stubs(:create).returns({}).at_least(0)
    Stripe::Customer.stubs(:retrieve).returns(stub(:card= => true, :save => true)).at_least(0)
    PayPal::SDK::REST::Payment.any_instance.expects(:create).returns(true).at_least(0)
    credit_card = mock()
    credit_card.stubs(:id).returns('CARD-ABC123').at_least(0)
    credit_card.stubs(:create).returns(true).at_least(0)
    PayPal::SDK::REST::CreditCard.stubs(:new).returns(credit_card).at_least(0)
  end
end

World(BillingGatewayHelper)
