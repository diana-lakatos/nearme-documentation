require 'test_helper'

class PaymentGateway::PaypalExpressPaymentGatewayTest < ActiveSupport::TestCase

  setup do
    @paypal_express_processor = FactoryGirl.build(:paypal_express_chain_payment_gateway, live_settings: {email: "sender@example.com"}, test_settings: {email: "sender@example.com"})
  end

  should "#setup_api_on_initialize should return a ActiveMerchant PaypalGateway object" do
    assert_equal ActiveMerchant::Billing::PaypalExpressGateway, @paypal_express_processor.class.active_merchant_class
  end

  should "have a refund identification based on its transaction_id key" do
    charge_response = ActiveMerchant::Billing::Response.new true, 'OK', { "transaction_id" => "123" }
    charge = Charge.new(response: charge_response)
    assert_equal "123", @paypal_express_processor.refund_identification(charge)
  end

  should "build correct boarding_url" do
    @company = create(:company)
    @merchant = @company.create_paypal_express_chain_merchant_account
    assert boarding_url, @paypal_express_processor.boarding_url(@merchant)
  end

  def boarding_url
    "https://www.paypal.com/webapps/merchantboarding/webflow/externalpartnerflow?partnerId=#{@paypal_express_processor.settings["partner_id"]}&productIntentID=addipmt&countryCode=US&integrationType=T&permissionNeeded=EXPRESS_CHECKOUT,REFUND,AUTH_CAPTURE,TRANSACTION_DETAILS,TRANSACTION_SEARCH,REFERENCE_TRANSACTION,BILLING_AGREEMENT&returnToPartnerUrl=https%3A%2F%2Fwww.github.com%2Fpaypal-return%2F&receiveCredentials=FALSE&showPermissions=TRUE&productSelectionNeeded=FALSE&merchantID=#{@merchant.merchant_token}"
  end
end
