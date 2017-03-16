# frozen_string_literal: true
require 'test_helper'
require 'twilio-ruby'

class CheckoutControllerTest < ActionController::TestCase
  setup do
    @reservation = FactoryGirl.create(:reservation_without_payment)
    @transactable = @reservation.transactable
    @payment_gateway = stub_billing_gateway(@transactable.instance)
    @payment_gateway.payment_methods.ach.first.update(active: false)
    @payment_method = @payment_gateway.payment_methods.credit_card.first
    @reservation.creator.update_attribute(:sms_notifications_enabled, true)
    sign_in @reservation.user
  end

  should 'track booking review open' do
    get :show, order_id: @reservation.id
    assert_response 200
  end

  context 'billing authorization' do
    setup do
      stub_store_card
    end

    should 'should not save on authorization failure' do
      authorize_response = OpenStruct.new(success?: false, error: 'No $$$ on account')
      PaymentGateway.any_instance.expects(:gateway_authorize).returns(authorize_response)
      assert_no_difference('Payment.count') do
        put :update, order_params_for(@reservation)
      end
    end

    should 'store successful authorization' do
      authorize_response = OpenStruct.new(success?: true, authorization: 'abc')
      PaymentGateway.any_instance.expects(:gateway_authorize).returns(authorize_response)
      put :update, order_params_for(@transactable)
      payment = Payment.last
      assert_equal 'abc', payment.authorization_token
      assert payment.authorized?
    end
  end

  should 'track booking request' do
    stub_active_merchant_interaction

    WorkflowStepJob.expects(:perform).with do |klass, _id|
      klass == WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation && assigns(:order).id
    end
    assert_no_difference 'Reservation.count' do
      put :update, order_params_for(@transactable)
    end

    assert_response :redirect
  end

  context 'schedule expiry' do
    should 'create a delayed_job task to run in 24 hours time when saved' do
      stub_active_merchant_interaction

      travel_to Time.zone.now do
        OrderExpiryJob.expects(:perform_later).with do |expires_at, _id|
          expires_at == 24.hours.from_now
        end
        put :update, order_params_for(@transactable)
      end
    end
  end

  context '#twilio' do
    context 'sending sms fails' do
      setup do
        stub_active_merchant_interaction
        Utils::DefaultAlertsCreator::ReservationCreator.new.notify_host_reservation_created_and_pending_confirmation_sms!
        stub_request(:post, 'https://www.googleapis.com/urlshortener/v1/url')
      end

      should 'raise invalid phone number exception if message indicates so' do
        Rails.logger.expects(:error).never
        User.any_instance.expects(:notify_about_wrong_phone_number).once
        Twilio::REST::RequestError.any_instance.stubs(:code).returns(21_614)
        SmsNotifier::Message.any_instance.stubs(:send_twilio_message).raises(Twilio::REST::RequestError, "The 'To' number +16665554444 is not a valid phone number")
        assert_nothing_raised do
          put :update, order_params_for(@transactable)
        end
        assert @response.body.include?('redirect')
        assert_redirected_to success_dashboard_order_path(Reservation.last)
      end
    end
  end

  private

  def order_params_for(_transactable)
    {
      order_id: @reservation.id,
      order: {
        payment_attributes: {
          payment_method_id: @payment_method.id,
          credit_card_attributes: {
            first_name: 'Jan',
            last_name: 'Kowalski',
            number: 4_242_424_242_424_242,
            month: '05',
            year: '2020',
            verification_value: '411'
          }
        }
      }
    }
  end
end
