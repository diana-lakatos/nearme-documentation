# frozen_string_literal: true
class Webhook::StripeWebhook < Webhook

  ALLOWED_EVENTS = %w{charge transfer account}

  def process!
    return false unless can_process_event?

    set_merchant_account

    "WebhookService::Stripe::#{event_base_type.capitalize}".constantize.new(
      event, payment_gateway, merchant_account
    ).parse_event! ? success! : failed!

  rescue => e
    process_error(e, should_raise: true)
  end

  private

  def can_process_event?
    return process_error('Mode mismatch') if payment_gateway_mode != payment_gateway.mode
    return process_error('Webhook not found') if event.blank?
    return process_error("Webhook type #{event.type} not allowed") unless event_known?

    increment!(:retry_count)

    true
  end

  def event_known?
    ALLOWED_EVENTS.include?(event_base_type)
  end

  def event_base_type
    event.type.split('.').first
  end

  def livemode?
    !!params['livemode']
  end

  def event
    @event ||= payment_gateway.parse_webhook(params[:id], params[:user_id])
  end

  def set_merchant_account
    return if params[:user_id].blank?

    self.merchant_account = payment_gateway.merchant_accounts.find_by!(external_id: params[:user_id])
  end
end
