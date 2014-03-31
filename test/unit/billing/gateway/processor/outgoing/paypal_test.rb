require 'test_helper'

class Billing::Gateway::Processor::Outgoing::PaypalTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @company = FactoryGirl.create(:company)
    @company.update_attribute(:paypal_email, 'receiver@example.com')
    @company.instance.update_attribute(:paypal_email, 'sender@example.com')
  end

  should "create a Payout record with reference, amount, currency, and success on success" do
    api_mock = mock()
    api_mock.expects(:build_pay)
    pay_response_mock = mock()
    pay_response_mock.stubs(:success? => true, :to_yaml => 'yaml', :paymentExecStatus => 'COMPLETED')
    api_mock.expects(:pay).returns(pay_response_mock)
    PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
    @paypal_processor = Billing::Gateway::Processor::Outgoing::Paypal.new(@company, 'EUR')
    @paypal_processor.expects(:payout_successful)
    @paypal_processor.process_payout(Money.new(1000, 'EUR'))
  end

  should "create a Payout record with pending when has to be confirmed" do
    api_mock = mock()
    api_mock.expects(:build_pay)
    pay_response_mock = mock()
    pay_response_mock.stubs(:success? => true, :to_yaml => 'yaml', :paymentExecStatus => 'CREATED')
    api_mock.expects(:pay).returns(pay_response_mock)
    PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
    @paypal_processor = Billing::Gateway::Processor::Outgoing::Paypal.new(@company, 'EUR')
    @paypal_processor.expects(:payout_pending).with(pay_response_mock)
    @paypal_processor.process_payout(Money.new(1000, 'EUR'))
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
    @paypal_processor = Billing::Gateway::Processor::Outgoing::Paypal.new(@company, 'EUR')
    @paypal_processor.expects(:payout_failed)
    @paypal_processor.process_payout(Money.new(1000, 'EUR'))
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
    @paypal_processor = Billing::Gateway::Processor::Outgoing::Paypal.new(@company, 'EUR')
    @paypal_processor.expects(:payout_successful)
    @paypal_processor.process_payout(Money.new(1234, 'EUR'))
  end

end
