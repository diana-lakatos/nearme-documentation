class ReservationChargeTrackerJob < Job
  def after_initialize(reservation_id)
    @reservation = Reservation.find_by_id(reservation_id)
  end

  def perform
    if @reservation && @reservation.confirmed?
      mixpanel_wrapper = AnalyticWrapper::MixpanelApi.new(AnalyticWrapper::MixpanelApi.mixpanel_instance, :current_user => @reservation.owner)
      event_tracker = Rails.application.config.event_tracker.new(mixpanel_wrapper, AnalyticWrapper::GoogleAnalyticsApi.new(@reservation.owner))
      event_tracker.track_charge(@reservation)
    else
      Rails.logger.info "Reservation with id '#{@reservation.try(:id)}' has been cancelled (or deleted), charge not tracked at all"
    end
  end
end
