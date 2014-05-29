require "test_helper"
require "vcr_setup"

class ComissionCalculationTest < ActionDispatch::IntegrationTest

  setup do
    stub_what_has_to_be_stubbed
    @instance = Instance.default_instance
    @instance.update_attribute(:service_fee_host_percent, 10)
    @instance.update_attribute(:service_fee_guest_percent, 15)
    @listing = FactoryGirl.create(:transactable, :daily_price => 25.00)
    
    FactoryGirl.create(:paypal_instance_payment_gateway)
    
    ipg = FactoryGirl.create(:stripe_instance_payment_gateway)
    @instance.instance_payment_gateways << ipg
    
    country_ipg = FactoryGirl.create(
      :country_instance_payment_gateway, 
      country_alpha2_code: "US", 
      instance_payment_gateway_id: ipg.id
    )
    @instance.country_instance_payment_gateways << country_ipg

    @reservation = FactoryGirl.create(:reservation_with_credit_card, listing: @listing)
    @billing_gateway = Billing::Gateway::Incoming.new(@reservation.owner, @instance, @reservation.currency)

    VCR.use_cassette("comission_calculation_test/authorize") do
      response = @billing_gateway.authorize(@reservation.total_amount_cents, credit_card)
      @reservation.create_billing_authorization(token: response[:token], payment_gateway_class: response[:payment_gateway_class])
      @reservation.save
    end

    @listing.company.update_attribute(:paypal_email, 'receiver@example.com')
    create_logged_in_user
  end

  should 'ensure that comission after payout is correct' do

    post_via_redirect "/listings/#{@listing.id}/reservations", booking_params
    
    VCR.use_cassette("comission_calculation_test/capture") do
      @reservation.confirm
    end

    post_via_redirect "/listings/#{FactoryGirl.create(:transactable).id}/reservations", booking_params

    @reservation_charge = @reservation.reservation_charges.last
    assert @reservation_charge.paid?
    assert_equal 2875, @reservation_charge.charge_attempts.successful.first.amount

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
