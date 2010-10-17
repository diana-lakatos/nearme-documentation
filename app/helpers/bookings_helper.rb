module BookingsHelper
  def booking_schedule_for(workplace, &block)
    workplace.schedule.each do |date, num_of_desks|
      availability = case num_of_desks
        when 0
          "booked"
        when 1, 2, 3
          "last_bookings"
        else
          "available"
      end

      yield(date, num_of_desks, availability)
    end
  end

end
