require "test_helper"

class ComissionCalculationTest < ActionDispatch::IntegrationTest

  setup do
    stub_what_has_to_be_stubbed
    @instance = Instance.default_instance
    @instance.update_attribute(:service_fee_host_percent, 10)
    @instance.update_attribute(:service_fee_guest_percent, 15)
    @listing = FactoryGirl.create(:listing, :daily_price => 25.00)
    @instance.update_attribute(:paypal_email, 'sender@example.com')
    @listing.company.update_attribute(:paypal_email, 'receiver@example.com')
    create_logged_in_user
  end

  should 'ensure that comission after payout is correct' do
    post_via_redirect "/listings/#{@listing.id}/reservations", booking_params
    Reservation.last.confirm!

    @reservation_charge = ReservationCharge.last
    assert @reservation_charge.paid?
    assert_equal 2875, @reservation_charge.charge_attempts.successful.first.amount

    PaymentTransferSchedulerJob.new.perform

    @payment_transfer = PaymentTransfer.last
    assert @payment_transfer.transferred?
    assert_equal 2250, @payment_transfer.payout_attemps.successful.first.amount
  end

  private

  def create_logged_in_user
    post_via_redirect '/users', :user => { :name => 'John Doe', :email => 'user@example.com', :password => 'password' }
    post_via_redirect '/users/sign_in', :user => { :email => 'user@example.com', :password => 'password' }
  end

  def stub_what_has_to_be_stubbed
    stub_mixpanel
    stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
    Company.any_instance.stubs(:has_payment_method?).returns(true)
    Billing::Gateway.any_instance.stubs(:store_credit_card).returns(true)
    Stripe::Charge.expects(:create).returns({})
    api_mock = mock()
    api_mock.expects(:build_pay)
    pay_response_mock = mock()
    pay_response_mock.stubs(:success? => true, :to_yaml => 'yaml')
    api_mock.expects(:pay).returns(pay_response_mock)
    PayPal::SDK::AdaptivePayments::API.expects(:new).returns(api_mock)
  end

  def booking_params
    {
      reservation_request: {
        dates: [Chronic.parse('Monday')],
        quantity: "1",
        card_number: "4111 1111 1111 1111",
        card_expires: 1.year.from_now.strftime("%m/%Y"),
        card_code: '111',
        country_name: 'United States',
        mobile_number: '57489473'
      }
    }
  end
end
