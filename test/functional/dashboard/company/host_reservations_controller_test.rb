require 'test_helper'

class Dashboard::Company::HostReservationsControllerTest < ActionController::TestCase

  context 'index' do

    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @related_company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
      @related_location = FactoryGirl.create(:location_in_auckland, company: @related_company)
      @related_listing = FactoryGirl.create(:transactable, location: @related_location)
      @unrelated_listing = FactoryGirl.create(:transactable)
      @unrelated_listing.update_attribute(:instance_id, FactoryGirl.create(:instance).id)
    end

    should 'show related guests and appropriate units' do
      @reservation = FactoryGirl.create(:unconfirmed_reservation, owner: @user, listing: @related_listing)
      @reservation.send(:schedule_expiry)

      get :index
      assert_response :success
      assert_select ".order", 1
      assert_select ".order .total-units p:last-child", "1 day"
      @related_listing.update!({booking_type: 'overnight'})
      get :index
      assert_response :success
      assert_select ".order .total-units p:last-child", "1 night"
    end

    should 'show related listings when no related guests' do
      @reservation = FactoryGirl.create(:reservation, owner: @user, listing: @unrelated_listing)
      @reservation.update_attribute(:instance_id, @unrelated_listing.instance_id)
      get :index
      assert_response :success
      assert_select ".order", 0
      assert_select "h2", @related_listing.name
    end

    should 'not show unrelated guests' do
      @reservation = FactoryGirl.create(:reservation, owner: @user, listing: @unrelated_listing)
      @reservation.update_attribute(:instance_id, @unrelated_listing.instance_id)
      get :index
      assert_response :success
      assert_select ".order", 0
    end

    should 'show reservation properly in correct time zones' do
      @user.update_attribute(:time_zone, 'Hawaii')
      Time.use_zone 'Hawaii' do
        Reservation.destroy_all
        reservation = FactoryGirl.create(:unconfirmed_reservation, owner: @user, listing: @related_listing)
        ReservationPeriod.destroy_all
        reservation.reload
        reservation.add_period(Time.zone.tomorrow, 600, 720) # Tommorow form 10:00 - 12:00 AM
        reservation.save
        reservation.send(:schedule_expiry)


        # Current time is before the reservation
        get :index
        assert_equal [reservation], assigns(:guest_list).reservations

        # Travel to time in the middle of reservation
        travel_to Time.zone.tomorrow.at_beginning_of_day.advance(hours: 11) do
          get :index
          assert_equal [reservation], assigns(:guest_list).reservations
        end

      end
    end

  end

  context 'other actions' do
    setup do
      @reservation = FactoryGirl.create(:unconfirmed_reservation)
      @payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
      @user = @reservation.listing.creator
      sign_in @user
      stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
      stub_billing_gateway(@reservation.instance)
      stub_active_merchant_interaction
      # @payment_gateway.authorize(@reservation.payment)
    end

    should "track and redirect a host to the Manage Guests page when they confirm a booking" do
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::ManuallyConfirmed, @reservation.id)

      Rails.application.config.event_tracker.any_instance.expects(:confirmed_a_booking).with do |reservation|
        reservation == assigns(:reservation)
      end
      Rails.application.config.event_tracker.any_instance.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).owner
      end
      Rails.application.config.event_tracker.any_instance.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).host
      end

      post :confirm, { id: @reservation.id }

      assert_redirected_to dashboard_company_host_reservations_path
    end

    should "track and redirect a host to the Manage Guests page when they reject a booking" do
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::Rejected, @reservation.id)

      Rails.application.config.event_tracker.any_instance.expects(:rejected_a_booking).with do |reservation|
        reservation == assigns(:reservation)
      end
      Rails.application.config.event_tracker.any_instance.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).owner
      end
      Rails.application.config.event_tracker.any_instance.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).host
      end
      Reservation.any_instance.expects(:schedule_void).once
      put :reject, { id: @reservation.id }
      assert_redirected_to dashboard_company_host_reservations_path
    end

    should "track and redirect a host to the Manage Guests page when they cancel a booking" do
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostCancelled, @reservation.id)

      @reservation.confirm # Must be confirmed before can be cancelled

      Rails.application.config.event_tracker.any_instance.expects(:cancelled_a_booking).with do |reservation, custom_options|
        reservation == assigns(:reservation) && custom_options == { actor: 'host' }
      end
      Rails.application.config.event_tracker.any_instance.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).owner
      end
      Rails.application.config.event_tracker.any_instance.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).host
      end
      Reservation.any_instance.stubs(:schedule_refund).returns(true)
      post :host_cancel, { id: @reservation.id }
      assert_redirected_to dashboard_company_host_reservations_path
    end

    should "refund booking on cancel" do
      @reservation = FactoryGirl.create(:confirmed_reservation)

      sign_in @reservation.listing.creator
      User.any_instance.stubs(:accepts_sms_with_type?)

      setup_refund_for_reservation(@reservation)

      assert_difference 'Refund.count' do
        post :host_cancel, { id: @reservation.id }
      end

      assert_redirected_to dashboard_company_host_reservations_path
      assert_equal 'refunded', @reservation.reload.payment.state
    end

    context 'PUT #reject' do
      should 'set rejection reason' do
        Reservation.any_instance.expects(:schedule_void).once
        put :reject, { id: @reservation.id, reservation: { rejection_reason: 'Dont like him' } }
        assert_equal @reservation.reload.rejection_reason, 'Dont like him'
      end
    end

    context 'versions' do

      should 'store new version after confirm' do
        assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count', 1) do
          with_versioning do
            post :confirm, { id: @reservation.id }
          end
        end
      end

      should 'store new version after reject' do
        Reservation.any_instance.expects(:schedule_void).once
        assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count') do
          with_versioning do
            put :reject, { id: @reservation.id, reservation: { rejection_reason: 'Dont like him' } }
          end
        end
      end

      should 'store new version after cancel' do
        Reservation.any_instance.stubs(:schedule_refund).returns(true)
        @reservation.confirm
        assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count') do
          with_versioning do
            post :host_cancel, { id: @reservation.id }
          end
        end
      end

    end

  end

  protected

  def setup_refund_for_reservation(reservation)
    reservation.payment.charges.successful.create(amount: reservation.total_amount_cents)
    PaymentGateway::StripePaymentGateway.any_instance.stubs(:refund_identification)
      .returns({id: "123"}.to_json)
    ActiveMerchant::Billing::StripeGateway.any_instance.stubs(:refund)
      .returns(ActiveMerchant::Billing::BogusGateway.new.refund(reservation.total_amount_cents, reservation.currency, "123"))
  end
end

