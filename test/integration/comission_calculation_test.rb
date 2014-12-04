require "test_helper"

class ComissionCalculationTest < ActionDispatch::IntegrationTest

  setup do
    stub_what_has_to_be_stubbed
    @instance = Instance.default_instance
    @instance.update_attribute(:service_fee_host_percent, 10)
    @instance.update_attribute(:service_fee_guest_percent, 15)
    @instance.update_attribute(:payment_transfers_frequency, 'daily')
    @listing = FactoryGirl.create(:transactable, :daily_price => 25.00)

    FactoryGirl.create(:paypal_instance_payment_gateway)

    @reservation = FactoryGirl.create(:reservation_with_credit_card, listing: @listing)
    stub_billing_gateway(@instance)
    stub_active_merchant_interaction
    @billing_gateway = Billing::Gateway::Incoming.new(@reservation.owner, @instance, @reservation.currency)

    response = @billing_gateway.authorize(@reservation.total_amount_cents, credit_card)
    @reservation.create_billing_authorization(token: response[:token], payment_gateway_class: response[:payment_gateway_class])
    @reservation.save!

    @listing.company.update_attribute(:paypal_email, 'receiver@example.com')
    create_logged_in_user
  end

  should 'ensure that comission after payout is correct' do

    post_via_redirect "/listings/#{@listing.id}/reservations", booking_params

    @reservation.confirm

    post_via_redirect "/listings/#{FactoryGirl.create(:transactable).id}/reservations", booking_params

    @reservation_charge = @reservation.reservation_charges.last
    charge = @reservation_charge.charge_attempts.new(amount: @reservation_charge.total_amount_cents, success: true)
    assert @reservation_charge.paid?
    assert_equal 2875, charge.amount

    PaymentTransferSchedulerJob.perform

    @payment_transfer = @reservation.company.payment_transfers.last
    assert_equal 1, @reservation.company.payment_transfers.count
    assert @payment_transfer.transferred?
    assert_equal 2250, @payment_transfer.payout_attempts.successful.first.amount
  end

  private

  def create_logged_in_user
    # TODO post_via_redirect '/users', :user => { :name => 'John Doe', :email => 'user@example.com', :password => 'password' }
    user = FactoryGirl.create(:user)
    post_via_redirect '/users/sign_in', :user => { :email => user.email, :password => user.password }
  end

  def stub_what_has_to_be_stubbed
    stub_mixpanel
    stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
    api_mock = mock()
    api_mock.expects(:build_pay)
    pay_response_mock = mock()
    pay_response_mock.stubs(:success? => true, :to_yaml => 'yaml', :paymentExecStatus => 'COMPLETED')
    api_mock.expects(:pay).returns(pay_response_mock)
    PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
  end

  def booking_params
    {
      reservation_request: {
        dates: [Chronic.parse('Monday')],
        quantity: "1",
        card_number: "4242 4242 4242 4242",
        card_expires: 1.year.from_now.strftime("%m/%Y"),
        card_code: '411',
        country_name: 'United States',
        mobile_number: '57489473'
      }
    }
  end

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      :number             => "4242424242424242",
      :month              => "12",
      :year               => "2020",
      :verification_value => "411"
    )
  end
end
