class ReservationPeriodDecorator < Draper::Decorator
  delegate_all

  delegate :hourly_summary, :minute_of_day_to_time, :start_minute_of_day_to_time, :end_minute_of_day_to_time, to: :hourly_presenter

  private

  def hourly_presenter
    @hourly_presenter ||= HourlyPresenter.new(date, start_minute, end_minute, time_zone)
  end

end
