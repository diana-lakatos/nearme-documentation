require 'test_helper'

class Billing::Gateway::Processor::Incoming::FetchTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.first
    @user = FactoryGirl.create(:user)
    @instance.country_instance_payment_gateways << FactoryGirl.create(:fetch_country_instance_payment_gateway)
    ActiveMerchant::Billing::Base.mode = :test
  end

  should "set fetch as processor for NZ companies" do
    @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, 'NZD', 'NZ')
    assert_equal Billing::Gateway::Processor::Incoming::Fetch, @billing_gateway.processor.class
  end

  should "not set fetch as processor for US companies" do
    @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, 'NZD', 'US')
    assert_nil @billing_gateway.processor
  end

  should "not set fetch as processor for NZ companies but with USD" do
    @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD', 'NZ')
    assert_nil @billing_gateway.processor
  end

  should "set reservation as paid after success response" do
    stub_request(:post, /https:\/\/(my|demo).fetchpayments.co.nz\/webpayments\/MNSHandler.aspx/)
      .to_return(:status => 200, :body => 'VERIFIED')

    @reservation = FactoryGirl.create(:reservation_with_remote_payment)
    @reservation.payment_response_params = SUCCESS_FETCH_RESPONSE
    @reservation.charge
    @reservation.reload

    assert_equal "paid", @reservation.payment_status
    assert_equal Payment.last, @reservation.payments.last
    assert_equal Charge.last, @charge = @reservation.payments.last.charges.last
    assert_equal true, @charge.success
    assert_equal SUCCESS_FETCH_RESPONSE, @charge.response
  end

  should "set reservation as failed after declined response" do
    stub_request(:post, /https:\/\/(my|demo).fetchpayments.co.nz\/webpayments\/MNSHandler.aspx/)
      .to_return(:status => 200, :body => 'DECLINED')

    @reservation = FactoryGirl.create(:reservation_with_remote_payment)
    @reservation.payment_response_params = FAILED_FETCH_RESPONSE
    @reservation.charge
    @reservation.reload

    assert_equal "failed", @reservation.payment_status
    assert_equal Payment.last, @reservation.payments.last
    assert_equal Charge.last, @charge = @reservation.payments.last.charges.last
    assert_equal false, @charge.success
    assert_equal FAILED_FETCH_RESPONSE, @charge.response
  end

  FETCH_RESPONSE = {
    "account_id" => "621380",
    "item_name" => "Super cat",
    "amount" => "1.03",
    "transaction_id" => "P150100005007408",
    "receipt_id" => "25001990",
    "verifier" => "6D1911F685372EF19E255A12691AAD74",
    "reservation_id" => "1"
  }

  SUCCESS_FETCH_RESPONSE = {
    "transaction_status" => "2",
    "response_text" => "Transaction Successful"
  }.merge(FETCH_RESPONSE)

  FAILED_FETCH_RESPONSE = {
    "transaction_status" => "11",
    "response_text" => "Transaction Failed"
  }.merge(FETCH_RESPONSE)

end
