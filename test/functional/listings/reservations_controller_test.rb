require 'test_helper'

class Listings::ReservationsControllerTest < ActionController::TestCase

  setup do
    @listing = FactoryGirl.create(:listing_in_san_francisco)

    @user = FactoryGirl.create(:user, name: "Example LastName")
    sign_in @user
    stub_mixpanel
    stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")

    @payment_gateway = stub_billing_gateway(@listing.instance)
    @payment_method = @payment_gateway.payment_methods.first
    stub_active_merchant_interaction

    ActiveMerchant::Billing::Base.mode = :test
  end

  should "track booking review open" do
    @tracker.expects(:reviewed_a_booking).with do |reservation|
      reservation == assigns(:reservation_request).reservation.decorate
    end
    post :review, booking_params_for(@listing)
    assert_response 200
  end

  context 'cancellation policy' do

    setup do
      TransactableType.update_all({
        cancellation_policy_enabled: Time.zone.now,
        cancellation_policy_hours_for_cancellation: 24,
        cancellation_policy_penalty_percentage: 60
      })
    end

    should 'store cancellation policy details if enabled' do
      post :create, booking_params_for(@listing)
      reservation = assigns(:reservation_request).reservation.reload
      assert_equal 24, reservation.cancellation_policy_hours_for_cancellation
      assert_equal 60, reservation.cancellation_policy_penalty_percentage
    end

    should 'not store cancellation policy details if disabled' do
      TransactableType.update_all(cancellation_policy_enabled: nil)
      post :create, booking_params_for(@listing)
      reservation = assigns(:reservation_request).reservation.reload
      assert_equal 0, reservation.cancellation_policy_hours_for_cancellation
      assert_equal 0, reservation.cancellation_policy_penalty_percentage
    end
  end

  context 'billing authorization' do
    should 'store failed authorization' do
      authorize_response = OpenStruct.new(success?: false, error: 'No $$$ on account')
      PaymentAuthorizer.any_instance.expects(:gateway_authorize).returns(authorize_response)
      post :create, booking_params_for(@listing)
      billing_authorization = @listing.reload.billing_authorizations.first
      assert_not_nil billing_authorization
      refute billing_authorization.success?
      assert_equal authorize_response, billing_authorization.response
      assert_nil billing_authorization.token
      assert_equal @user.id, billing_authorization.user_id
      assert_not_equal @listing.creator_id, billing_authorization.user_id
    end

    should 'store successful authorization' do
      authorize_response = OpenStruct.new(success?: true, authorization: 'abc')
      PaymentAuthorizer.any_instance.expects(:gateway_authorize).returns(authorize_response)
      post :create, booking_params_for(@listing)
      assert_nil @listing.reload.billing_authorizations.first
      billing_authorization = assigns(:reservation).billing_authorization
      assert billing_authorization.success?
      assert_equal authorize_response, billing_authorization.response
      assert_equal 'abc', billing_authorization.token
      assert_equal @user.id, billing_authorization.user_id
      assert_not_equal @listing.creator_id, billing_authorization.user_id
    end
  end

  should "track booking request" do

    WorkflowStepJob.expects(:perform).with do |klass, id|
      klass == WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation && assigns(:reservation_request).reservation.id
    end

    @tracker.expects(:requested_a_booking).with do |reservation|
      reservation == assigns(:reservation_request).reservation
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation_request).reservation.owner
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation_request).reservation.host
    end

    assert_difference 'Reservation.count' do
      post :create, booking_params_for(@listing)
    end

    assert_response :redirect
  end

  context 'schedule expiry' do

    should 'create a delayed_job task to run in 24 hours time when saved' do
      travel_to Time.zone.now do
        ReservationExpiryJob.expects(:perform_later).with do |hours, id|
          hours == 24.hours
        end
        post :create, booking_params_for(@listing)
      end
    end

  end

  context "#twilio" do

    context 'sending sms fails' do

      setup do
        Utils::DefaultAlertsCreator::ReservationCreator.new.notify_host_reservation_created_and_pending_confirmation_sms!
      end

      should 'raise invalid phone number exception if message indicates so' do
        Rails.logger.expects(:error).never
        User.any_instance.expects(:notify_about_wrong_phone_number).once
        Twilio::REST::RequestError.any_instance.stubs(:code).returns(21614)
        SmsNotifier::Message.any_instance.stubs(:send_twilio_message).raises(Twilio::REST::RequestError, "The 'To' number +16665554444 is not a valid phone number")
        assert_nothing_raised do
          post :create, booking_params_for(@listing)
        end
        assert @response.body.include?('redirect')
        assert_redirected_to booking_successful_dashboard_user_reservation_path(Reservation.last)
      end

    end

  end

  context 'versions' do

    should 'store new version after creating reservation' do
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "create").count') do
        with_versioning do
          post :create, booking_params_for(@listing)
        end
      end
    end

  end

  context 'Book It Out' do
    setup do
      @transactable = FactoryGirl.create(:transactable, :fixed_price, :with_book_it_out)
      @transactable.transactable_type.update_attributes! action_book_it_out: true
      @params = booking_params_for(@transactable)
      next_available_occurrence = Time.parse(@transactable.next_available_occurrences.first[:id])
      @params[:reservation_request].merge!({book_it_out: "true", dates: next_available_occurrence, quantity: 10})

    end

    should 'create reservation with discount' do
      post :create, @params
      reservation = Reservation.last
      assert_redirected_to booking_successful_dashboard_user_reservation_path(Reservation.last)
      assert_equal reservation.book_it_out_discount, @transactable.book_it_out_discount
      assert_equal reservation.subtotal_amount, @transactable.quantity * @transactable.fixed_price * ( 1 - @transactable.book_it_out_discount / 100.to_f)
      assert_not_equal reservation.subtotal_amount, @transactable.quantity * @transactable.fixed_price
    end

    should 'not create reservation with discount and wrong quantity' do
      @params[:reservation_request].merge!({quantity: 8})
      post :create, @params
      assert_response 200
      assert response.body.include?(I18n.t('reservations_review.errors.book_it_out_quantity'))
    end

    should 'not create reservation with discount if it is turned off' do
      @transactable.transactable_type.update_attributes! action_book_it_out: false
      post :create, @params
      assert_response 200
      assert response.body.include?(I18n.t('reservations_review.errors.book_it_out_not_available'))
    end

  end

  context 'Exclusive Price' do
    setup do
      @transactable = FactoryGirl.create(:transactable, :fixed_price, :with_exclusive_price)
      @transactable.transactable_type.update_attributes! action_exclusive_price: true
      @params = booking_params_for(@transactable)
      next_available_occurrence = Time.parse(@transactable.next_available_occurrences.first[:id])
      @params[:reservation_request].merge!({ dates: next_available_occurrence.to_date, quantity: 10, exclusive_price: "true" })
    end

    should 'create reservation with exclusive price' do
      post :create, @params
      reservation = Reservation.last
      assert_redirected_to booking_successful_dashboard_user_reservation_path(Reservation.last)
      assert_equal reservation.exclusive_price, @transactable.exclusive_price
      assert_equal reservation.subtotal_amount, @transactable.exclusive_price
      assert_not_equal reservation.subtotal_amount, @transactable.quantity * @transactable.fixed_price
    end

    should 'not create reservation with discount if it is turned off' do
      @transactable.transactable_type.update_attributes! action_exclusive_price: false
      post :create, @params
      assert_response 200
      assert response.body.include?(I18n.t('reservations_review.errors.exclusive_price_not_available'))
    end

  end

  context 'Price per unit' do
    setup do
      @transactable = FactoryGirl.create(:transactable, :fixed_price)
      @transactable.transactable_type.update_attributes! action_price_per_unit: true
      @params = booking_params_for(@transactable)
      next_available_occurrence = Time.parse(@transactable.next_available_occurrences.first[:id])
      @params[:reservation_request].merge!({ dates: next_available_occurrence.to_date, quantity: 11.23 })
    end

    should 'create reservation with price per unit' do
      post :create, @params
      reservation = Reservation.last
      assert_redirected_to booking_successful_dashboard_user_reservation_path(Reservation.last)
      assert_equal reservation.subtotal_amount, @transactable.fixed_price * @params[:reservation_request][:quantity]
      assert_equal 11.23, reservation.quantity
    end

  end

  private

  def booking_params_for(listing)
    {
      listing_id: listing.id,
      reservation_request: {
        dates: [Chronic.parse('Monday')],
        quantity: "1",
        card_number: 4242424242424242,
        card_exp_month: '05',
        card_exp_year: '2020',
        card_code: "411",
        payment_method_id: @payment_method.id
      }
    }
  end

  def object_hash_for(reservation)
    {
      booking_desks: reservation.quantity,
      booking_days: reservation.total_days,
      booking_currency: reservation.currency,
      booking_total: reservation.total_amount_dollars,
      location_address: reservation.location.address,
      location_suburb: reservation.location.suburb,
      location_city: reservation.location.city,
      location_state: reservation.location.state,
      location_country: reservation.location.country,
      location_postcode: reservation.location.postcode
    }
  end

end
