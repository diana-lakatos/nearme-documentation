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

    should 'show related guests' do
      FactoryGirl.create(:reservation, owner: @user, listing: @related_listing)
      get :index
      assert_response :success
      assert_select ".order", 1
    end

    should 'show related locations when no related guests' do
      @reservation = FactoryGirl.create(:reservation, owner: @user, listing: @unrelated_listing)
      @reservation.update_attribute(:instance_id, @unrelated_listing.instance_id)
      get :index
      assert_response :success
      assert_select ".order", 0
      assert_select "h2", @related_location.name
    end

    should 'not show unrelated guests' do
      @reservation = FactoryGirl.create(:reservation, owner: @user, listing: @unrelated_listing)
      @reservation.update_attribute(:instance_id, @unrelated_listing.instance_id)
      get :index
      assert_response :success
      assert_select ".order", 0
    end

    should 'show tweet links if no reservation' do
      get :index
      assert_response :success
      assert_select ".sharelocation", 1
      assert_select ".sharelocation > span", 4
    end

    should 'not show tweet links if there is reservation' do
      FactoryGirl.create(:reservation, owner: @user, listing: @related_listing)
      get :index
      assert_response :success
      assert_select ".sharelocation", 0
    end

  end

  context 'other actions' do
    setup do
      @reservation = FactoryGirl.create(:reservation_with_credit_card)
      @reservation.create_billing_authorization(token: "123", payment_gateway_class: "Billing::Gateway::Processor::Incoming::Stripe", payment_gateway_mode: "test")
      @user = @reservation.listing.creator
      sign_in @user
      stub_mixpanel
      stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
      stub_billing_gateway(@reservation.instance)
      stub_active_merchant_interaction
    end

    should "track and redirect a host to the Manage Guests page when they confirm a booking" do
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::ManuallyConfirmed, @reservation.id)

      @tracker.expects(:confirmed_a_booking).with do |reservation|
        reservation == assigns(:reservation)
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).owner
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).host
      end

      post :confirm, { id: @reservation.id }

      assert_redirected_to dashboard_company_host_reservations_path
    end

    should "track and redirect a host to the Manage Guests page when they reject a booking" do
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::Rejected, @reservation.id)

      @tracker.expects(:rejected_a_booking).with do |reservation|
        reservation == assigns(:reservation)
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).owner
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).host
      end
      put :reject, { id: @reservation.id }
      assert_redirected_to dashboard_company_host_reservations_path
    end

    should "track and redirect a host to the Manage Guests page when they cancel a booking" do
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::HostCancelled, @reservation.id)

      @reservation.confirm # Must be confirmed before can be cancelled

      @tracker.expects(:cancelled_a_booking).with do |reservation, custom_options|
        reservation == assigns(:reservation) && custom_options == { actor: 'host' }
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).owner
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).host
      end
      post :host_cancel, { id: @reservation.id }
      assert_redirected_to dashboard_company_host_reservations_path
    end

    should "refund booking on cancel" do
      ActiveMerchant::Billing::Base.mode = :test
      gateway.authorize(@reservation.total_amount_cents, credit_card)
      @reservation.confirm

      sign_in @reservation.listing.creator
      User.any_instance.stubs(:accepts_sms_with_type?)

      setup_refund_for_reservation(@reservation)

      assert_difference 'Refund.count' do
        post :host_cancel, { id: @reservation.id }
      end

      assert_redirected_to dashboard_company_host_reservations_path
      assert_equal 'refunded', @reservation.reload.payment_status
    end

    context 'PUT #reject' do
      should 'set rejection reason' do
        put :reject, { id: @reservation.id, reservation: { rejection_reason: 'Dont like him' } }
        assert_equal @reservation.reload.rejection_reason, 'Dont like him'
      end
    end

    context 'versions' do

      should 'store new version after confirm' do
        # 2 because attempt charge is triggered, which if successful generates second version
        assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count', 2) do
          with_versioning do
            post :confirm, { id: @reservation.id }
          end
        end
      end

      should 'store new version after reject' do
        assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count') do
          with_versioning do
            put :reject, { id: @reservation.id, reservation: { rejection_reason: 'Dont like him' } }
          end
        end
      end

      should 'store new version after cancel' do
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

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      :number             => "4242424242424242",
      :month              => "12",
      :year               => "2020",
      :verification_value => "411"
    )
  end

  def gateway
    Billing::Gateway::Processor::Incoming::ProcessorFactory.create(@user, @user.instance, "USD", 'US')
  end

  def setup_refund_for_reservation(reservation)
    reservation.payments.last.charges.successful.create(amount: reservation.total_amount_cents)
    Billing::Gateway::Processor::Incoming::Stripe.any_instance.stubs(:refund_identification)
      .returns({id: "123"}.to_json)
    ActiveMerchant::Billing::StripeGateway.any_instance.stubs(:refund)
      .returns(ActiveMerchant::Billing::BogusGateway.new.refund(reservation.total_amount_cents, "123"))
  end
end
