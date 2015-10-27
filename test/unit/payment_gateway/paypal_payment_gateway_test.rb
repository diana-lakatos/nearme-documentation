require 'test_helper'

class PaymentGateway::PaypalPaymentGatewayTest < ActiveSupport::TestCase
  context 'PayPal Payments Pro' do

    setup do
      @paypal_processor = FactoryGirl.build(:paypal_payment_gateway, live_settings: {email: "sender@example.com"}, test_settings: {email: "sender@example.com"})
    end

    should "#setup_api_on_initialize should return a ActiveMerchant PaypalGateway object" do
      assert_equal ActiveMerchant::Billing::PaypalGateway, @paypal_processor.class.active_merchant_class
    end

    should "have a refund identification based on its transaction_id key" do
      charge_response = ActiveMerchant::Billing::Response.new true, 'OK', { "transaction_id" => "123" }
      charge = Charge.new(response: charge_response)
      assert_equal "123", @paypal_processor.refund_identification(charge)
    end
  end

  context 'PayPal Adaptive Payments' do

    setup do
      @paypal_adaptive_processor = FactoryGirl.build(:paypal_adaptive_payment_gateway, live_settings: {email: "sender@example.com"}, test_settings: {email: "sender@example.com"})
      @company = FactoryGirl.create(:company)
      @merchant_account = FactoryGirl.create(:paypal_adaptive_merchant_account, payment_gateway: @paypal_adaptive_processor, merchantable: @company, email: 'receiver@example.com' )
    end

    should "create a Payout record with reference, amount, currency, and success on success" do
      api_mock = mock()
      api_mock.expects(:build_pay)
      pay_response_mock = mock()
      pay_response_mock.stubs(:success? => true, :to_yaml => 'yaml', :paymentExecStatus => 'COMPLETED')
      api_mock.expects(:pay).returns(pay_response_mock)
      PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
      @paypal_adaptive_processor.expects(:payout_successful)

      @paypal_adaptive_processor.process_payout(@merchant_account, Money.new(1000, 'EUR'), nil)
    end

    should "create a Payout record with pending when has to be confirmed" do
      api_mock = mock()
      api_mock.expects(:build_pay)
      pay_response_mock = mock()
      pay_response_mock.stubs(:success? => true, :to_yaml => 'yaml', :paymentExecStatus => 'CREATED')
      api_mock.expects(:pay).returns(pay_response_mock)
      PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
      @paypal_adaptive_processor.expects(:payout_pending).with(pay_response_mock)
      @paypal_adaptive_processor.process_payout(@merchant_account, Money.new(1000, 'EUR'), nil)
    end

    should "create a Payout record with failure on failure" do
      api_mock = mock()
      api_mock.expects(:build_pay)
      pay_response_mock = mock()
      error_mock = mock()
      error_mock.stubs(:to_yaml => 'yaml')
      pay_response_mock.stubs(:success?).returns(false)
      pay_response_mock.stubs(:error).returns(error_mock)
      api_mock.expects(:pay).returns(pay_response_mock)
      PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
      @paypal_adaptive_processor.expects(:payout_failed)
      @paypal_adaptive_processor.process_payout(@merchant_account, Money.new(1000, 'EUR'), nil)
    end

    should 'build pay object with right arguments' do
      api_mock = mock()
      api_mock.expects(:build_pay).with({
        :actionType => "PAY",
        :currencyCode => 'EUR',
        :feesPayer => "SENDER",
        :cancelUrl => "http://example.com",
        :returnUrl => "http://example.com",
        :receiverList => {
          :receiver => [{
            :amount => '12.34',
            :email => 'receiver@example.com'
          }]
        },
        :senderEmail => 'sender@example.com'
      })
      PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
      pay_response_mock = mock()
      pay_response_mock.stubs(:success? => true, :to_yaml => 'yaml', :paymentExecStatus => 'COMPLETED')
      api_mock.expects(:pay).returns(pay_response_mock)
      @paypal_adaptive_processor.expects(:payout_successful)
      @paypal_adaptive_processor.process_payout(@merchant_account, Money.new(1234, 'EUR'), nil)
    end
  end

end
