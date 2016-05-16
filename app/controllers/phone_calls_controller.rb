class PhoneCallsController < ApplicationController
  class NoVerifiedPhoneNumber < Exception; end

  rescue_from Twilio::REST::RequestError, with: :request_error
  rescue_from NoVerifiedPhoneNumber, with: :unverified_error

  skip_before_filter :set_locale
  before_action :authenticate_user!, only: [:new, :create, :destroy]

  before_action :redirect_back, only: [:new, :create, :destroy]
  before_action :find_user, only: [:new, :create, :destroy]
  before_action :phone_call_possible?, only: [:new, :create]

  def new
  end

  def create
    @call = client.call(
      to: current_user.communication.phone_number,
      from: current_instance.twilio_config[:from],
      url: connect_webhooks_phone_calls_url,
      status_callback: status_webhooks_phone_calls_url
    )

    current_user.outgoing_phone_calls.create({
      from: current_user.communication.phone_number,
      receiver_id: @user.id,
      to: @user.communication.phone_number,
      phone_call_key: @call.sid
    })
  end

  def destroy
    client.hang_up(params[:id])
  end

  private

  def find_user
    @user = User.find params[:user_id]
  end

  def client
    Communication::TwilioProvider.new(
      current_instance.twilio_config[:key],
      current_instance.twilio_config[:secret]
    )
  end

  def phone_call_possible?
    unless current_user.communication.try(:verified?)
      raise NoVerifiedPhoneNumber, I18n.t('errors.messages.communications.not_verified.current_user')
    end

    unless @user.communication.try(:verified?)
      raise NoVerifiedPhoneNumber, I18n.t('errors.messages.communications.not_verified.listing_owner')
    end
  end

  def redirect_back
    redirect_to :back if not request.xhr?
  end

  def request_error(exception)
    @exception = exception
    render action: :error
  end

  def unverified_error(exception)
    @exception = exception
    render action: :unverified
  end

end
