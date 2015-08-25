require 'test_helper'
class MerchantAccount::PaypalExpressChainMerchantAccountTest < ActiveSupport::TestCase

  setup do
    @instance = current_instance
    @company = create(:company)
    @payout_gateway = FactoryGirl.create :paypal_express_chain_payment_gateway
    @merchant = @company.create_paypal_express_chain_merchant_account(payment_gateway: @payout_gateway)
  end

  should "create_billing_agreement"
  should "destroy_billing_agreement"

  should "generate merchant token" do
    assert @merchant.merchant_token.present?
  end

  should "have a redirect url" do
    assert @merchant.redirect_url.present?
  end

  should "have a subject" do
    @merchant.billing_agreement_id = nil
    assert @merchant.subject.nil?
    @merchant.billing_agreement_id = "bill_id"
    @merchant.payer_id = "pay_id"

    assert_equal @merchant.subject, @merchant.payer_id
  end

  should "return a boolean value for #chain_payment_set?" do
    assert [true, false].include?(@merchant.chain_payment_set?)
  end

  should "be able to boarding_complete" do
    response = {
      "merchantIdInPayPal" => "123124ID",
      "permissionsGranted" => "true",
      "consentStatus" => "true",
      "accountStatus" => "BUSINESS_ACCOUNT",
      "productIntentID" => "addipmt",
      "returnMessage" => "Thanks for buying!",
      "isEmailConfirmed" => "true"
    }

    @merchant.boarding_complete(response)
    assert (@merchant.state == 'verified')

    response["merchantIdInPayPal"] = nil

    @merchant.state = 'pending'
    @merchant.save!

    @merchant.reload.boarding_complete(response)
    assert (@merchant.state == 'failed')
  end
end
