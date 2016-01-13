require 'test_helper'

class PaymentGateway::PaypalExpressChainPaymentGatewayTest < ActiveSupport::TestCase

  setup do
    @paypal_express_chain_processor = FactoryGirl.build(:paypal_express_chain_payment_gateway)
  end

  should "include test in settings" do
    assert @paypal_express_chain_processor.settings[:test]
  end

  should "#setup_api_on_initialize should return a ActiveMerchant PaypalGateway object" do
    assert_equal ActiveMerchant::Billing::PaypalExpressGateway, @paypal_express_chain_processor.class.active_merchant_class
  end

  should "have a refund identification based on its transaction_id key" do
    charge_response = ActiveMerchant::Billing::Response.new true, 'OK', { "transaction_id" => "123" }
    charge = Charge.new(response: charge_response)
    assert_equal "123", @paypal_express_chain_processor.refund_identification(charge)
  end

  should "build correct boarding_url" do
    @company = create(:company)
    @merchant = @company.create_paypal_express_chain_merchant_account
    assert boarding_url, @paypal_express_chain_processor.boarding_url(@merchant)
  end

  def boarding_url
    "https://www.paypal.com/webapps/merchantboarding/webflow/externalpartnerflow?partnerId=#{@paypal_express_chain_processor.settings["partner_id"]}&productIntentID=addipmt&countryCode=US&integrationType=T&permissionNeeded=EXPRESS_CHECKOUT,REFUND,AUTH_CAPTURE,TRANSACTION_DETAILS,TRANSACTION_SEARCH,REFERENCE_TRANSACTION,BILLING_AGREEMENT&returnToPartnerUrl=https%3A%2F%2Fwww.github.com%2Fpaypal-return%2F&receiveCredentials=FALSE&showPermissions=TRUE&productSelectionNeeded=FALSE&merchantID=#{@merchant.merchant_token}"
  end

  context "When making refund" do
    setup do
      ActiveMerchant::Billing::PaypalExpressGateway.any_instance.stubs(:refund).returns(OpenStruct.new(success: true, success?: true, refunded_ammount: 1000))

      @paypal_express_chain_processor.save
      @paypal_express_chain_processor.stubs(:refund_identification).returns('payout_identification')
    end

    should 'use test mode for test charge' do
      payment = FactoryGirl.create(:test_charge).payment
      refund_payment(payment)
      assert_equal 'test', payment.refunds.last.payment_gateway_mode
    end

    should 'use live mode for live charge' do
      payment = FactoryGirl.create(:live_charge).payment
      refund_payment(payment)
      assert_equal 'live', payment.refunds.last.payment_gateway_mode
    end

    should 'refund full amount when host cancel' do
      charge = FactoryGirl.create(:test_charge)
      payment = charge.payment
      payment.update_attributes(cancellation_policy_penalty_percentage: 50)
      refund_payment(payment)
      assert_equal payment.payable.total_service_fee_amount_cents, payment.refunds.order(:id).last.amount
      assert_equal charge.amount, payment.refunds.order(:id).first.amount
    end

    should 'apply cancelation fee when guest cancel' do
      charge = FactoryGirl.create(:test_charge)
      payment = charge.payment
      payment.update_attributes(cancellation_policy_penalty_percentage: 50)
      refund_payment(payment, "user_cancel")

      # Service fee is refunded to Host. MPO doesn't get anything when guest cancel reservation
      assert_equal payment.payable.total_service_fee_amount_cents, payment.refunds.order(:id).last.amount
      # 50% cancellation policy apply + service fee is not refundable
      # 50% of 100$ subtotal should be refunded to guest, the rest 60$ is left on HOST account!
      assert_equal 5000, payment.refunds.order(:id).first.amount
    end
  end

  def refund_payment(payment, refund_with="host_cancel")
    payment.payable.mark_as_paid!
    Reservation.any_instance.stubs(:payment_gateway).returns(@paypal_express_chain_processor)
    Reservation.any_instance.stubs(:active_merchant_payment?).returns(true)

    assert payment.paid?
    payment.payable.send(refund_with)
    assert payment.reload.refunded?
  end
end
