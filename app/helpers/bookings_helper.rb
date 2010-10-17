module BookingsHelper
  def booking_schedule_for(workplace, weeks = 1, &block)
    new_row = false

    workplace.schedule(weeks).to_a.in_groups_of(5).each do |group|
      group.each do |date, num_of_desks|
        availability = case num_of_desks
          when 0
            "booked"
          when 1, 2, 3
            "last_bookings"
          else
            "available"
        end

        yield(date, num_of_desks, availability, new_row)
        new_row = false
      end

      new_row = true
    end
  end

end
