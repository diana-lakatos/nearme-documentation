require 'test_helper'

class ExpressCheckoutControllerTest < ActionController::TestCase
  setup do
    details = OpenStruct.new(params: { "payer_id": 'payer_identification' })
    ActiveMerchant::Billing::PaypalExpressGateway.any_instance.stubs(:details_for).returns(details)
    @payment_method = FactoryGirl.create(:paypal_express_payment_method)
    @payment = FactoryGirl.create(:pending_payment, :paypal_express, express_token: 'token', payment_method: @payment_method)

    @reservation = @payment.payable
    sign_in @reservation.user
  end

  should 'return to reservation after cancel' do
    get :cancel, order_id: @reservation.id, token: 'token'
    assert_redirected_to order_checkout_path(@reservation)
    assert @reservation.reload.inactive?
  end

  should 'return to booking successful page after success' do
    response = OpenStruct.new(success?: true, authorization: '54533')
    ActiveMerchant::Billing::PaypalExpressGateway.any_instance.stubs(:authorize).returns(response)

    get :return, order_id: @reservation.id, token: 'token', "PayerID": 'payer_identification'
    assert_redirected_to dashboard_order_path(@reservation)
    assert @reservation.reload.unconfirmed?
  end
end
