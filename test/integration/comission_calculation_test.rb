require "test_helper"

class ComissionCalculationTest < ActionDispatch::IntegrationTest

  setup do
    stub_what_has_to_be_stubbed
    @instance = Instance.first
    @instance.update_attribute(:service_fee_host_percent, 10)
    @instance.update_attribute(:service_fee_guest_percent, 15)
    @instance.update_attribute(:payment_transfers_frequency, 'daily')
    @listing = FactoryGirl.create(:transactable, :daily_price => 25.00)

    @listing.transactable_type.update_attribute(:service_fee_host_percent, 10)
    @listing.transactable_type.update_attribute(:service_fee_guest_percent, 15)
    @instance.update_attribute(:payment_transfers_frequency, 'daily')

    CountryPaymentGateway.delete_all
    payment_gateway = FactoryGirl.create(:paypal_payment_gateway)
    FactoryGirl.create(:country_payment_gateway, payment_gateway: payment_gateway, country_alpha2_code: 'US')
    FactoryGirl.create(:paypal_merchant_account, payment_gateway: payment_gateway, merchantable: @listing.company)

    @reservation = FactoryGirl.create(:reservation_with_credit_card, listing: @listing)
    stub_billing_gateway(@instance)
    stub_active_merchant_interaction
    @billing_gateway = @instance.payment_gateway('US', @reservation.currency)

    response = @billing_gateway.authorize(@reservation.total_amount_cents, credit_card)
    @reservation.create_billing_authorization(token: response[:token], payment_gateway: payment_gateway)
    @reservation.save!

    create_logged_in_user
  end

  should 'ensure that comission after payout is correct' do

    post_via_redirect "/listings/#{@listing.id}/reservations", booking_params

    @reservation.confirm

    post_via_redirect "/listings/#{FactoryGirl.create(:transactable).id}/reservations", booking_params

    @payment = @reservation.payments.last
    assert @payment.paid?
    charge = @payment.charges.new(amount: @payment.total_amount_cents, success: true)
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
    instance = Instance.first
    instance.domains << FactoryGirl.create(:domain, name: "www.example.com")
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
        card_exp_month: 1.year.from_now.month.to_s,
        card_exp_year: 1.year.from_now.year.to_s,
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
