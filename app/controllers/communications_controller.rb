class CommunicationsController < ApplicationController
  rescue_from Twilio::REST::RequestError, with: :request_error

  before_action :authenticate_user!, only: [:create, :destroy, :verified]

  def create

    phone = params[:phone] || current_user.full_mobile_number

    # Check if caller is already verfied on the provider server
    caller = client.get_by_phone_number(phone)

    if caller
      add_validated_caller(caller)
    else
      verify_new_caller(phone)
    end
  end

  def destroy
    communication = current_user.communication
    caller = client.disconnect_number(communication.phone_number_key)
    communication.destroy

    flash[:notice] = I18n.t("flash_messages.communications.phone_number_disconnected")
    redirect_to edit_dashboard_click_to_call_preferences_path
  end

  def verified
    if current_user.communication.try(:verified?)
      render json: { status: true, phone: current_user.full_mobile_number }
    else
      render json: { status: false }
    end
  end

  def verified_success
    flash[:notice] = I18n.t("flash_messages.communications.successfully_connected")
    redirect_to edit_dashboard_click_to_call_preferences_path
  end

  private

  def client
    Communication::TwilioProvider.new(
      current_instance.twilio_config[:key],
      current_instance.twilio_config[:secret]
    )
  end

  def request_error(exception)
    if request.xhr?
      render json: { status: 'error', message: exception.message }
    else
      redirect_to edit_dashboard_click_to_call_preferences_path, flash: { error: exception.message }
    end
  end

  def add_validated_caller(caller)

    current_user.communication = current_user.build_communication(
      provider: 'twilio',
      provider_key: caller.account_sid,
      phone_number: caller.phone_number,
      phone_number_key: caller.sid,
      request_key: nil,
      verified: true
    )

    if request.xhr?
      render json: { status: 'verified', phone: caller.phone_number }
    else
      flash[:notice] = I18n.t("flash_messages.communications.successfully_connected")
      redirect_to edit_dashboard_click_to_call_preferences_path
    end
  end

  def verify_new_caller(phone)
    caller = client.verify_number(
      current_user.name,
      phone,
      status_webhooks_communications_url
      )

    current_user.communication = current_user.build_communication(
      provider: 'twilio',
      provider_key: caller.account_sid,
      phone_number: caller.phone_number,
      phone_number_key: nil,
      request_key: caller.call_sid,
      verified: false
      )

    message = I18n.t('flash_messages.communications.validation_code', validation_code: caller.validation_code)

    if request.xhr?
      render json: { status: 'new', message: caller.validation_code, poll_url: verified_user_communications_path(current_user) }
    else
      flash[:notice] = message
      redirect_to edit_dashboard_click_to_call_preferences_path
    end
  end

end
