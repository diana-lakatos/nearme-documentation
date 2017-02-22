require 'test_helper'

class PaymentGateway::FetchPaymentGatewayTest < ActiveSupport::TestCase
  setup do
    @payment_gateway = FactoryGirl.create(:fetch_payment_gateway)
  end

  should 'set fetch as processor for NZ companies with NZD currency' do
    assert_equal ['NZD'], @payment_gateway.supported_currencies
    assert_equal ['NZ'], @payment_gateway.class.supported_countries
  end

  should 'set reservation as paid after success response' do
    stub_request(:post, /https:\/\/(my|demo).fetchpayments.co.nz\/webpayments\/MNSHandler.aspx/)
      .to_return(status: 200, body: 'VERIFIED')

    @reservation = FactoryGirl.create(:reservation_with_remote_payment, currency: 'NZD')
    @reservation.payment.payment_response_params = SUCCESS_FETCH_RESPONSE
    assert_difference 'Charge.count' do
      @reservation.charge_and_confirm!
    end
    @reservation.reload

    assert @reservation.paid?
    assert_equal Payment.last, @reservation.payment
    assert_equal Charge.last, @charge = @reservation.payment.charges.last
    assert @charge.success
    assert_equal OpenStruct.new(success?: true, message: parse_params(SUCCESS_FETCH_RESPONSE)), @charge.response
  end

  should 'set reservation as failed after declined response' do
    stub_request(:post, /https:\/\/(my|demo).fetchpayments.co.nz\/webpayments\/MNSHandler.aspx/)
      .to_return(status: 200, body: 'DECLINED')

    @reservation = FactoryGirl.create(:reservation_with_remote_payment, currency: 'NZD')
    @reservation.payment.payment_response_params = FAILED_FETCH_RESPONSE
    assert_difference 'Charge.count' do
      @reservation.charge_and_confirm!
    end
    @reservation.reload
    assert @reservation.payment.authorized?
    @charge = @reservation.payment.charges.last
    refute @charge.success
    assert_equal OpenStruct.new(success?: false, message: parse_params(FAILED_FETCH_RESPONSE)), @charge.response
  end

  def parse_params(mns_params)
    mns_params.reject! { |k, _v| %w(action controller reservation_id).include?(k) }
    mns_params.each { |k, v| mns_params[k] = v.gsub(/\s+/, '%20') }
    mns_params.merge!('cmd' => '_xverify-transaction')
    mns_params
  end

  FETCH_RESPONSE = {
    'account_id' => '621380',
    'item_name' => 'Super cat',
    'amount' => '1.03',
    'transaction_id' => 'P150100005007408',
    'receipt_id' => '25001990',
    'verifier' => '6D1911F685372EF19E255A12691AAD74',
    'reservation_id' => '1'
  }

  SUCCESS_FETCH_RESPONSE = {
    'transaction_status' => '2',
    'response_text' => 'Transaction Successful'
  }.merge(FETCH_RESPONSE)

  FAILED_FETCH_RESPONSE = {
    'transaction_status' => '11',
    'response_text' => 'Transaction Failed'
  }.merge(FETCH_RESPONSE)
end
