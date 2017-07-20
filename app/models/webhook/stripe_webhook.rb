# frozen_string_literal: true
class Webhook::StripeWebhook < Webhook

  ALLOWED_EVENTS = %w{charge transfer account payout}

  delegate :livemode?, to: :event

  def process!
    return true if success?
    return false unless can_process_event?
    set_merchant_account

    "WebhookService::Stripe::#{event_base_type.capitalize}".constantize.new(
      event, payment_gateway, merchant_account, fetch_object?
    ).parse_event! ? success! : failed!

  rescue => e
    process_error(e, should_raise: true)
  end

  private

  # We want to fetch related object from Stripe in case of error
  # error can indicate that object is processed in uknown version
  # that's why we are retrying in version specified in codebase
  def fetch_object?
    retry_count > 1 && error.present?
  end

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

  def event
    @event ||= response_object
  end

  def set_merchant_account
    return if event.user_id.blank?

    self.merchant_account = payment_gateway.merchant_accounts.find_by!(external_id: event.user_id)
  end
end
