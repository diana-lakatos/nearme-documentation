require "test_helper"

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
      @listing.update!({ booking_type: 'overnight' })
      create_reservation!
      confirm_reservation!
      schedule_payment_transfer!
    end
  end

  private

  def create_logged_in_user
    @guest = FactoryGirl.create(:user)
    post_via_redirect '/users/sign_in', :user => { :email => @guest.email, :password => @guest.password }
  end

  def relog_to_host
    delete_via_redirect '/users/sign_out'
    post_via_redirect '/users/sign_in', :user => { :email => @reservation.creator.email, :password => 'password' }
  end

  def relog_to_guest
    delete_via_redirect '/users/sign_out'
    post_via_redirect '/users/sign_in', :user => { :email => @guest.email, :password => 'password' }
  end

  def stub_what_has_to_be_stubbed
    stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
    api_mock = mock()
    api_mock.expects(:build_pay)
    api_mock.expects(:pay).returns(OpenStruct.new(:success? => true, :to_yaml => 'yaml', :paymentExecStatus => 'COMPLETED'))
    PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
  end

  def booking_params
    {
      reservation_request: {
        dates: @listing.booking_type == 'overnight' ? [Chronic.parse('Monday'), Chronic.parse('Tuesday')] : [Chronic.parse('Monday')],
        quantity: "1",
        payment_attributes: {
          payment_method_id: @payment_method.id,
          credit_card_attributes: {
            number: "4111 1111 1111 1111",
            month: 1.year.from_now.month.to_s,
            year: 1.year.from_now.year.to_s,
            verification_value: '411',
            first_name: 'Maciej',
            last_name: 'Krajowski',
          }
        }
      }
    }
  end

  def mockup_database_with_currency(currency = 'USD')
    stub_what_has_to_be_stubbed
    @instance = PlatformContext.current.instance
    @instance.update_attribute(:service_fee_host_percent, 10)
    @instance.update_attribute(:service_fee_guest_percent, 15)
    @instance.update_attribute(:payment_transfers_frequency, 'daily')
    FactoryGirl.create(:additional_charge_type, currency: 'USD', amount: 15)
    @listing = FactoryGirl.create(:transactable, currency: currency, :daily_price => 25.00)

    @listing.transactable_type.update_attribute(:service_fee_host_percent, 10)
    @listing.transactable_type.update_attribute(:service_fee_guest_percent, 15)
    @instance.update_attribute(:payment_transfers_frequency, 'daily')

    payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
    payout_gateway = FactoryGirl.create(:paypal_adaptive_payment_gateway)
    currency = Currency.find_by_iso_code(currency) || FactoryGirl.create(:currency, iso_code: currency)
    payout_gateway.payment_currencies << currency unless payout_gateway.payment_currencies.include?(currency)
    @payment_method = payment_gateway.payment_methods.first

    FactoryGirl.create(:paypal_adaptive_merchant_account, payment_gateway: payout_gateway, merchantable: @listing.company)
    Company.any_instance.stubs(:payout_payment_gateway).returns(payout_gateway)
    Instance.any_instance.stubs(:payment_gateway).returns(payment_gateway)
    PaymentTransfer.any_instance.stubs(:billing_gateway).returns(payout_gateway)
    PaymentGateway.any_instance.stubs(:supported_currencies).returns([currency])

    create_logged_in_user
  end

  def create_reservation!
    stub_billing_gateway(@instance)
    # todo: this is proper way of stubbing probably - only 3rd party gateway integration, need to use it globally
    stubs = {
      authorize: OpenStruct.new(authorization: "54533", success?: true),
      capture: OpenStruct.new(success?: true),
      refund: OpenStruct.new(success?: true),
      void: OpenStruct.new(success?: true)
    }
    gateway = stub(capture: stubs[:capture], refund: stubs[:refund], void: stubs[:void],)
    gateway.expects(:authorize).with do |total_amount_cents, credit_card_or_token, options|
      total_amount_cents == 43.75.to_money(@listing.currency).cents
    end.returns(stubs[:authorize])

    card_stub = OpenStruct.new(success?: true, params: {
      "object" => 'customer',
      "id" => 'customer_1',
      "default_source" => 'card_1',
      "cards" => {
        "data" => [
          { "id" => "card_1" }
        ]
      }
    })

    PaymentGateway::StripePaymentGateway.any_instance.stubs(:store).returns(card_stub)
    PaymentGateway::StripePaymentGateway.any_instance.stubs(:gateway).returns(gateway).at_least(0)
    PaymentGateway::StripePaymentGateway.any_instance.stubs(:credit_card_payment?).returns(true)
    assert_difference "@listing.reservations.count" do
      post_via_redirect "/listings/#{@listing.id}/reservations", booking_params
    end

    @reservation = @listing.reservations.last
    assert_not_nil @listing.reservations.last.billing_authorization
    refute @listing.reservations.last.billing_authorization.immediate_payout
    assert_equal @listing.currency, @reservation.currency
    assert_equal 25.to_money(@listing.currency), @reservation.subtotal_amount
    assert_equal 3.75.to_money(@listing.currency), @reservation.service_fee_amount_guest  if %w(USD IQD).include?(@listing.currency)
    assert_equal 18.75.to_money(@listing.currency), @reservation.service_fee_amount_guest + @reservation.service_additional_charges
    assert_equal 2.5.to_money(@listing.currency), @reservation.service_fee_amount_host if %w(USD IQD).include?(@listing.currency)
    assert_equal 43.75.to_money(@listing.currency), @reservation.total_amount
    assert_equal 1, @reservation.additional_charges.count
    additional_charge = @reservation.additional_charges.last
    assert_equal @listing.currency, additional_charge.currency
    assert_equal 15.to_money(@listing.currency), additional_charge.amount

  end

  def confirm_reservation!
    relog_to_host

    assert_difference "Charge.count", 1 do
      post_via_redirect "/dashboard/company/host_reservations/#{@reservation.id}/confirm"
    end

    assert @reservation.reload.confirmed?
    @payment = @reservation.payment
    assert @payment.paid?
    relog_to_guest
    charge = @payment.charges.last
    assert_equal 43.75.to_money(@listing.currency), charge.amount_money
  end

  def schedule_payment_transfer!
    PaymentTransferSchedulerJob.perform
    @payment_transfer = @reservation.company.payment_transfers.last
    assert_equal 1, @reservation.company.payment_transfers.count
    assert @payment_transfer.transferred?
    assert_equal 22.5.to_money(@listing.currency), @payment_transfer.payout_attempts.successful.first.amount_money
    assert_equal 18.75.to_money(@listing.currency), @payment_transfer.service_fee_amount_guest if %w(USD IQD).include?(@listing.currency)
    assert_equal 2.5.to_money(@listing.currency), @payment_transfer.service_fee_amount_host if %w(USD IQD).include?(@listing.currency)
  end

end
