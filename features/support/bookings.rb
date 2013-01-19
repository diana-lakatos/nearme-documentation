module Bookings
  def start_to_book(listing, dates, qty = 1)
    visit listing_path listing
    select qty.to_s, :from => "quantity"
    add_dates(dates)
  end

  def add_dates(dates)
    find(:css, ".calendar-wrapper").click

    wait_until {
      page.has_no_selector?('.datepicker-loading', visible: true)
    }

    added_dates = []
    dates.each do | date|
      unless added_dates.include?(date)
        el = find(:css, datepicker_class_for(date))
        el.click
        added_dates << date
      end
    end

    find(:css, ".calendar-wrapper").click
  end


  def datepicker_class_for(date)
    year = date.strftime('%Y')
    month = date.strftime('%m').to_i - 1 # - 1 because month JS is (0..11)
    day = date.strftime('%d').to_i
    ".datepicker-day-#{year}-#{month}-#{day}"
  end

  def next_regularly_available_day
    Chronic.parse('Monday')
  end

end

World(Bookings)
