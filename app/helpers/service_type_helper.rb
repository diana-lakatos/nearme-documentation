module ServiceTypeHelper

  def overnight_or_regular_booking?(service_type)
    service_type.regular_booking_enabled? || service_type.overnight_booking_enabled?
  end
  
end