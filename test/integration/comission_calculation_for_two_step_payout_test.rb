# frozen_string_literal: true
require 'test_helper'

class ComissionCalculationForTwoStepPayoutTest < ActionDispatch::IntegrationTest
  context 'regular two-step payout' do
    should 'ensure that comission after payout is correct with VND which has 10 - 1 subunit conversion rate' do
      mockup_database_with_currency('VND')
      create_reservation!
      confirm_reservation!
      schedule_payment_transfer!
    end

    should 'ensure that comission after payout is correct with IQD which has 1000 - 1 subunit conversion rate' do
      mockup_database_with_currency('IQD')
      create_reservation!
      confirm_reservation!
      schedule_payment_transfer!
    end

    should 'ensure that comission after payout is correct with MGA which has 5 - 1 subunit conversion rate' do
      mockup_database_with_currency('MGA')
      create_reservation!
      confirm_reservation!
      schedule_payment_transfer!
    end

    should 'ensure that comission after payout is correct with JPY which has 1 - 1 subunit conversion rate' do
      mockup_database_with_currency('JPY')
      create_reservation!
      confirm_reservation!
      schedule_payment_transfer!
    end

    should 'ensure that comission after payout is correct with USD which has 100 - 1 subunit conversion rate' do
      mockup_database_with_currency('USD')
      create_reservation!
      confirm_reservation!
      schedule_payment_transfer!
    end

    should 'ensure that comission after payout is correct with USD which has 100 - 1 subunit conversion rate for overnight booking' do
      mockup_database_with_currency('USD')
      @transactable.update!(booking_type: 'overnight')
      create_reservation!
      confirm_reservation!
      schedule_payment_transfer!
    end
  end

  private

  def create_logged_in_user
    @guest = FactoryGirl.create(:user)
    post_via_redirect '/users/sign_in', user: { email: @guest.email, password: @guest.password }
  end

  def relog_to_host
    delete_via_redirect '/users/sign_out'
    post_via_redirect '/users/sign_in', user: { email: @order.creator.email, password: 'password' }
  end

  def relog_to_guest
    delete_via_redirect '/users/sign_out'
    post_via_redirect '/users/sign_in', user: { email: @guest.email, password: 'password' }
  end

  def stub_what_has_to_be_stubbed
    stub_request(:post, 'https://www.googleapis.com/urlshortener/v1/url')
    api_mock = mock
    api_mock.expects(:build_pay)
    api_mock.expects(:pay).returns(OpenStruct.new(success?: true, to_yaml: 'yaml', paymentExecStatus: 'COMPLETED'))
    PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
  end

  def booking_params
    {
      order: {
        dates: @transactable.action_type.night_booking? ? [Chronic.parse('next week Monday'), Chronic.parse('next week Tuesday')] : [Chronic.parse('Monday')],
        quantity: '1',
        transactable_pricing_id: @transactable.action_type.pricings.first.id,
        transactable_id: @transactable.id
      }
    }
  end

  def checkout_params
    {
      order: {
        payment_attributes: {
          payment_method_id: @payment_method.id,
          credit_card_attributes: {
            number: '4111 1111 1111 1111',
            month: 1.year.from_now.month.to_s,
            year: 1.year.from_now.year.to_s,
            verification_value: '411',
            first_name: 'Maciej',
            last_name: 'Krajowski'
          }
        }
      }
    }
  end

  def mockup_database_with_currency(currency = 'USD')
    stub_what_has_to_be_stubbed
    @instance = PlatformContext.current.instance
    @instance.update_attribute(:payment_transfers_frequency, 'daily')
    FactoryGirl.create(:additional_charge_type, currency: currency, amount: 15)
    @transactable = FactoryGirl.create(:transactable, :with_time_based_booking, currency: currency)
    @transactable.action_type.pricing_for('1_day').update! price: 25
    @transactable.action_type.transactable_type_action_type.update_attribute(:service_fee_host_percent, 10)
    @transactable.action_type.transactable_type_action_type.update_attribute(:service_fee_guest_percent, 15)
    @instance.update_attribute(:payment_transfers_frequency, 'daily')

    payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
    payout_gateway = FactoryGirl.create(:paypal_adaptive_payment_gateway)
    currency = Currency.find_by(iso_code: currency) || FactoryGirl.create(:currency, iso_code: currency)
    payout_gateway.payment_currencies << currency unless payout_gateway.payment_currencies.include?(currency)
    @payment_method = payment_gateway.payment_methods.credit_card.first

    FactoryGirl.create(:paypal_adaptive_merchant_account, payment_gateway: payout_gateway, merchantable: @transactable.company)
    Company.any_instance.stubs(:payout_payment_gateway).returns(payout_gateway)
    Instance.any_instance.stubs(:payment_gateway).returns(payment_gateway)
    PaymentTransfer.any_instance.stubs(:billing_gateway).returns(payout_gateway)
    PaymentGateway.any_instance.stubs(:supported_currencies).returns([currency])

    create_logged_in_user
  end

  def create_reservation!
    stub_billing_gateway(@instance)
    # TODO: this is proper way of stubbing probably - only 3rd party gateway integration, need to use it globally
    stubs = {
      authorize: OpenStruct.new(authorization: '54533', success?: true),
      capture: OpenStruct.new(success?: true),
      refund: OpenStruct.new(success?: true),
      void: OpenStruct.new(success?: true)
    }
    gateway = stub(capture: stubs[:capture], refund: stubs[:refund], void: stubs[:void])
    gateway.expects(:authorize).with do |total_amount_cents, _credit_card_or_token, _options|
      total_amount_cents == 43.75.to_money(@transactable.currency).cents
    end.returns(stubs[:authorize])

    card_stub = OpenStruct.new(success?: true, params: {
                                 'object' => 'customer',
                                 'id' => 'customer_1',
                                 'default_source' => 'card_1',
                                 'cards' => {
                                   'data' => [
                                     { 'id' => 'card_1' }
                                   ]
                                 }
                               })

    PaymentGateway::StripePaymentGateway.any_instance.stubs(:store).returns(card_stub)
    PaymentGateway::StripePaymentGateway.any_instance.stubs(:gateway).returns(gateway).at_least(0)
    PaymentGateway::StripePaymentGateway.any_instance.stubs(:credit_card_payment?).returns(true)

    assert_difference '@transactable.orders.reservations.count' do
      post_via_redirect "/listings/#{@transactable.id}/orders", booking_params
    end

    @order = @transactable.orders.last

    put_via_redirect "/orders/#{@order.id}/checkout", checkout_params

    assert_not_nil @transactable.orders.reservations.last.payment.successful_billing_authorization
    refute @transactable.orders.reservations.last.payment.successful_billing_authorization.immediate_payout
    assert_equal @transactable.currency, @order.currency
    # assert_equal 25.to_money(@transactable.currency), @order.subtotal_amount
    assert_equal 25.to_money(@transactable.currency), @order.unit_price
    assert_equal 3.75.to_money(@transactable.currency), @order.service_fee_amount_guest if %w(USD IQD).include?(@transactable.currency)
    assert_equal 15.00.to_money(@transactable.currency), @order.service_additional_charges
    assert_equal 18.75.to_money(@transactable.currency), @order.service_fee_amount_guest + @order.service_additional_charges
    assert_equal 2.5.to_money(@transactable.currency), @order.service_fee_amount_host if %w(USD IQD).include?(@transactable.currency)
    assert_equal 43.75.to_money(@transactable.currency), @order.total_amount
    assert_equal 1, @order.additional_line_items.count
    additional_charge = @order.additional_line_items.last
    assert_equal @transactable.currency, additional_charge.currency
    assert_equal 15.to_money(@transactable.currency), additional_charge.total_price
  end

  def confirm_reservation!
    relog_to_host

    assert_difference 'Charge.count', 1 do
      post_via_redirect "/dashboard/company/host_reservations/#{@order.id}/confirm"
    end

    assert @order.reload.confirmed?
    @payment = @order.payment
    assert @payment.paid?
    relog_to_guest
    charge = @payment.charges.last
    assert_equal 43.75.to_money(@transactable.currency), charge.amount_money
  end

  def schedule_payment_transfer!
    PaymentTransferSchedulerJob.perform
    @payment_transfer = @order.company.payment_transfers.last
    assert_equal 1, @order.company.payment_transfers.count
    assert @payment_transfer.transferred?
    assert_equal 18.75.to_money(@transactable.currency), @payment_transfer.service_fee_amount_guest if %w(USD IQD).include?(@transactable.currency)
    assert_equal 2.5.to_money(@transactable.currency), @payment_transfer.service_fee_amount_host if %w(USD IQD).include?(@transactable.currency)
    assert_equal 22.5.to_money(@transactable.currency), @payment_transfer.payout_attempts.successful.first.amount_money
  end
end
