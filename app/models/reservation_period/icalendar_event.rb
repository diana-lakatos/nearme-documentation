class ReservationPeriod
  module IcalendarEvent

    def to_ics
      event = Icalendar::Event.new
      event.start = ics_date(date, start_minute)
      event.end = ics_date(date, end_minute)
      event.summary = self.reservation.listing.name
      event.description = self.reservation.location.street  + " - " + self.reservation.listing.name
      event.location = self.reservation.listing.location.address
      event.klass = "PUBLIC"
      event.created = self.reservation.created_at
      event.last_modified = self.reservation.updated_at
      event.uid = event.url = Rails.application.routes.url_helpers.reservation_url(self.reservation, :period => self.id)
      event
    end 

    def ics_date(date, minutes)
      date.strftime("%Y%m%dT") + time_in_ics_format(minutes)
    end

    def time_in_ics_format(minutes)
      hour = minutes/60.floor
      minute = minutes - (hour * 60)
      "#{"%02d" % hour}#{"%02d" % minute}00"
    end
  end

end
