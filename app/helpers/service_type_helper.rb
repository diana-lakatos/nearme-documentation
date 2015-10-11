module ServiceTypeHelper

  def overnight_or_regular_booking?(service_type)
    service_type.regular_booking_enabled? || service_type.overnight_booking_enabled?
  end

  def only_one_option_available?(transactable, type)
    service_type = transactable.service_type
    transactable.send("action_#{type}_booking") ||
      [
        service_type.action_subscription_booking,
        service_type.action_hourly_booking,
        service_type.action_free_booking,
        service_type.daily_options_names.any?
      ].select(&:present?).size == 1
  end

end