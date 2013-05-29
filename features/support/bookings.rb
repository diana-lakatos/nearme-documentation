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
    ensure_datepicker_open(".calendar-wrapper.date-start")
    select_datepicker_date(start_date)

    if dates.length > 0
      # This is a hack to move from the range mode to the pick mode
      select_datepicker_date(start_date)

      dates.each do | date|
        ensure_datepicker_open('.calendar-wrapper.date-end')
        select_datepicker_date(date)
      end

      # Close the datepicker
      find(:css, ".calendar-wrapper.date-end").click
    end
  end

  def ensure_datepicker_open(klass)
    if page.has_no_selector?('.dnm-datepicker', visible: true)
      find(:css, klass).click
    end
  end

  def select_datepicker_date(date)
    ensure_datepicker_is_on_right_month(date)
    el = find(:css, datepicker_class_for(date), :visible => true)
    el.click
  end

  def ensure_datepicker_is_on_right_month(date)
    if date > Date.today && !find(:css, '.datepicker-month', :visible => true).text.include?(Date::MONTHNAMES[date.month])
      find(:css, '.datepicker-next', :visible => true).click
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

  def extract_reservation_options(table)
    table.hashes.map do |data|
      listing = model!(data['Listing'])
      date = Chronic.parse(data['Date']).to_date

      qty = data['Quantity'].to_i
      qty = 1 if qty < 1

      if data['Start']
        start_hour, start_min = data['Start'].split(':').map(&:to_i)
        start_minute = start_hour * 60 + start_min
        start_at = Time.new(date.year, date.month, date.day, start_hour, start_min)
      end

      if data['End']
        end_hour, end_min = data['End'].split(':').map(&:to_i)
        end_minute = end_hour * 60 + end_min
        end_at = Time.new(date.year, date.month, date.day, end_hour, end_min)
      end

      { :listing => listing, :date => date, :quantity => qty,
        :start_minute => start_minute, :end_minute => end_minute,
        :start_at => start_at, :end_at => end_at }
    end
  end
end

World(Bookings)
