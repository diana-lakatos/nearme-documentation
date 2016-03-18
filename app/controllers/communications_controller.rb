class CommunicationsController < ApplicationController
  rescue_from Twilio::REST::RequestError, with: :request_error

  before_action :authenticate_user!, only: [:create, :destroy]

  def create
    caller = client.verify_number(
      current_user.name,
      current_user.full_mobile_number,
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

    flash[:notice] = I18n.t('flash_messages.communications.validation_code', validation_code: caller.validation_code)
    redirect_to social_accounts_path
  end

  def destroy
    communication = current_user.communication
    caller = client.disconnect_number(communication.phone_number_key)
    communication.destroy

    flash[:notice] = I18n.t("flash_messages.communications.phone_number_disconnected")
    redirect_to social_accounts_path
  end

  private

  def client
    Communication::TwilioProvider.new(
      current_instance.twilio_config[:key],
      current_instance.twilio_config[:secret]
    )
  end

  def request_error(exception)
    redirect_to social_accounts_path, flash: {error: exception.message}
  end

end
