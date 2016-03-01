require 'test_helper'

class PaymentGateway::PaypalExpressChainPaymentGatewayTest < ActiveSupport::TestCase

  setup do
    @paypal_express_chain_processor = FactoryGirl.build(:paypal_express_chain_payment_gateway)
    @payment_method = @paypal_express_chain_processor.payment_methods.first
    Payment.any_instance.stubs(:immediate_payout?).returns(true)
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
    end

    should 'use test mode for test charge' do
      payment = FactoryGirl.create(:paid_payment, payment_method: @payment_method, company: create(:company) )

      # Needed to imitate "imidiate payout" where we create payment transfer directly after payment is placed

      refund_payment(payment.reload)

      assert payment.reload.refunded?
      assert_equal 2, payment.refunds.successful.count
      assert_equal payment.payment_gateway_mode, payment.refunds.last.payment_gateway_mode
    end

    should 'use live mode for live charge' do
      PaymentGateway::PaypalExpressChainPaymentGateway.any_instance.stubs(:mode).returns('live')
      payment = FactoryGirl.create(:paid_payment, payment_method: @payment_method, company: create(:company))

      # Needed to imitate "imidiate payout" where we create payment transfer directly after payment is placed

      refund_payment(payment, "host_cancel", 'live')

      assert payment.reload.refunded?
      assert_equal 2, payment.refunds.successful.count
      assert_equal payment.payment_gateway_mode, payment.refunds.last.payment_gateway_mode
    end

    should 'refund full amount when host cancel' do
      payment = FactoryGirl.create(:paid_payment, payment_method: @payment_method, company: create(:company) )

      # Needed to imitate "imidiate payout" where we create payment transfer directly after payment is placed
      refund_payment(payment)

      assert payment.reload.refunded?
      assert_equal 2, payment.refunds.successful.count
      assert_equal payment.payment_gateway_mode, payment.refunds.last.payment_gateway_mode
      # We have 2 refunds first from MPO to seller (service_fee) second total amount from Seller to Guest
      assert_equal payment.payment_transfer.total_service_fee + payment.amount, Money.new(payment.refunds.sum(:amount))
      assert_equal payment.amount, Money.new(payment.refunds.guest.successful.last.amount)
      assert_equal payment.payment_transfer.total_service_fee, Money.new(payment.refunds.host.successful.last.amount)
    end

    should 'should not refund service fee twice' do
      ActiveMerchant::Billing::PaypalExpressGateway.any_instance.unstub(:refund)
      success_response = OpenStruct.new(success: true, success?: true, refunded_ammount: 1000)
      failed_response = OpenStruct.new(success: false, success?: false, refunded_ammount: 1000)

      ActiveMerchant::Billing::PaypalExpressGateway.any_instance.stubs(:refund).returns(success_response).then.returns(failed_response).then.returns(success_response)

      payment = FactoryGirl.create(:paid_payment, payment_method: @payment_method, company: create(:company) )

      # Needed to imitate "imidiate payout" where we create payment transfer directly after payment is placed
      refund_payment(payment)
      assert_equal 1, payment.refunds.successful.count

      refund_payment(payment)
      assert_equal 1, payment.refunds.successful.count
      refute payment.reload.refunded?
    end

    should 'apply cancelation fee when guest cancel' do
      payment = FactoryGirl.create(:paid_payment,
        payment_method: @payment_method,
        company: create(:company),
        cancellation_policy_penalty_percentage: 50,
        service_fee_amount_host_cents: 100)

      # Needed to imitate "imidiate payout" where we create payment transfer directly after payment is placed

      refund_payment(payment, "user_cancel")

      # Host Service Fee is refunded to Host. MPO gets guest service fee
      assert_equal payment.payment_transfer.service_fee_amount_host, Money.new(payment.refunds.host.successful.first.amount)
      assert_equal 100, payment.payment_transfer.service_fee_amount_host_cents
      # 50% cancellation policy apply + service fee is not refundable
      # 50% of 100$ subtotal should be refunded to guest, the rest 60$ is left on HOST account!
      assert_equal payment.amount_to_be_refunded, payment.refunds.guest.successful.first.amount
      assert_equal 50_00, payment.amount_to_be_refunded
    end
  end

  def refund_payment(payment, refund_with="host_cancel", mode="test")
    payout_response = ActiveMerchant::Billing::PaypalExpressResponse.new(true, 'OK', { "id" => "123", "message" => "message", "transaction_id" => 'payout_123' })

    payment_transfer = payment.company.payment_transfers.create!(payments: [payment.reload], payment_gateway_mode: mode, payment_gateway: payment.payment_gateway)
    payout = payment_transfer.payout_attempts.create(amount: payment_transfer.amount)
    payout.payout_successful(payout_response)

    assert payment.paid?
    payment.payable.send(refund_with)
  end
end
