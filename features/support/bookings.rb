module Bookings
  def start_to_book(listing, dates, qty = 1)
    visit location_path listing.location
    select qty.to_s, :from => "quantity"
    add_dates(dates)
  end

  def add_dates(dates)
    dates.uniq!

    # Select start date
    start_date = dates.shift

    # First date is auto selected
    unless start_date == listing.first_available_date
      find(:css, ".calendar-wrapper.date-start").click
      select_datepicker_date(start_date)
    end

    if dates.length > 0
      find(:css, ".calendar-wrapper.date-end").click

      # This is a hack to move from the range mode to the pick mode
      select_datepicker_date(start_date)

      dates.each do | date|
        select_datepicker_date(date)
      end

      # Close the datepicker
      find(:css, ".calendar-wrapper.date-end").click
    end
  end

  def select_datepicker_date(date)
    ensure_datepicker_is_on_right_month(date)
    wait_until_datepicker_finished_loading
    el = find(:css, datepicker_class_for(date), :visible => true)
    el.click
  end

  def ensure_datepicker_is_on_right_month(date)
    if date > Date.today && !find(:css, '.datepicker-month', :visible => true).text.include?(Date::MONTHNAMES[date.month])
      find(:css, '.datepicker-next', :visible => true).click
      wait_until_datepicker_finished_loading
    end
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

  def wait_until_datepicker_finished_loading
    wait_until { page.has_no_selector?('.datepicker-loading', visible: true) }
  end
end

World(Bookings)
