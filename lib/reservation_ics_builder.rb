require 'ri_cal'

# Helper class to build calendar ics file for given reservation
class ReservationIcsBuilder
  def initialize(reservation, user)
    @reservation = reservation
    @user = user
    build
  end

  def to_s
    @calendar.to_s.gsub("\n", "\r\n")
  end

  private

  def build
    @calendar ||= RiCal.Calendar do |cal|
      cal.add_x_property 'X-WR-CALNAME', @reservation.transactable.company.instance.name
      cal.add_x_property 'X-WR-RELCALID', "#{@user.id}"
      @reservation.periods.order('date ASC').find_each do |period|
        cal.event do |event|
          event.description = @reservation.transactable.description || ''
          event.summary = @reservation.transactable.name || ''
          event.uid = "#{@reservation.id}_#{period.date}"
          hour = period.start_minute / 60.floor
          minute = period.start_minute - (hour * 60)
          event.dtstart = period.date.strftime('%Y%m%dT') + "#{'%02d' % hour}#{'%02d' % minute}00"
          hour = period.end_minute / 60.floor
          minute = period.end_minute - (hour * 60)
          event.dtend = period.date.strftime('%Y%m%dT') + "#{'%02d' % hour}#{'%02d' % minute}00"
          event.created = @reservation.created_at
          event.last_modified = @reservation.updated_at
          event.location = @reservation.transactable.address || ''
          event.url = Rails.application.routes.url_helpers.dashboard_user_reservations_url(id: @reservation.id, host: PlatformContext.current.instance.default_domain.name)
        end
      end
    end
  end
end
