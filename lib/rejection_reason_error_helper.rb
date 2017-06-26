# frozen_string_literal: true
module RejectionReasonErrorHelper
  def rejection_error_messages(record)
    errors = [t('flash_messages.manage.reservations.reservation_not_confirmed')]
    errors << t('flash_messages.orders.rejection_reason_is_too_long') if record.errors['rejection_reason'].present?
    errors.join("\n")
  end
end
