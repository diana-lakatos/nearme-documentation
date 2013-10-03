module DashboardHelper

  def in_new_listing?
    (params[:action] == 'new' || params[:action] == 'edit') && params[:controller].include?('listings') && params[:id].blank?
  end

  def in_new_or_edit?
    params[:action] != 'new' && params[:action] != 'edit'
  end

  def dashboard_company_nav_class(company)
    classes = []

    if @location && @location.company == company
      classes << 'expanded'
    elsif @company && @company == company
      classes << 'active'
    end

    classes.join ' '
  end

  def dashboard_location_nav_class(location)
    classes = []

    if @location && @location == location
      classes << 'active'
    end

    classes.join ' '
  end

  def bookings_time_to_expiry(reservation)
    if reservation.state == 'unconfirmed'
      " - " + time_to_expiry(reservation.expiry_time) + " to expiry"
    end
  end

  def time_to_expiry(time_of_event)
    current_time = Time.zone.now
    total_seconds = time_of_event - current_time
    hours = (total_seconds/1.hour).floor
    minutes = ((total_seconds-hours.hours)/1.minute).floor
    if hours < 1 and minutes < 1
      'less than minute'
    else
      if hours < 1
        '%d minutes' % [minutes]
      else
        '%d hours, %d minutes' % [hours, minutes]
      end
    end
  end

  def manage_guests_time_to_expiry(reservation)
    if reservation.state == 'unconfirmed'
      expiry_time = reservation.expiry_time
      "Booking expires in #{time_to_expiry(expiry_time)}"
    end
  end

  def guest_filter_class(guest_list, filter)
    guest_list.state == filter ? 'btn-gray active' : 'btn-gray-darker'
  end

  def periods_dates(periods)
    periods.map(&:date).map{ |date| date.to_s(:db) }
  end

  def group_visits(visits)
    @grouped_visits ||= begin
      values = {}
      visits.map do |visit|
        values[visit.impression_date] ||= 0
        values[visit.impression_date] += visit.impressions_count.to_i
      end
      values
    end
  end

  def visits_for_chart(visits)
    [group_visits(visits).values]
  end

  def visits_labels_for_chart(visits)
    impression_dates = group_visits(visits).keys
    if impression_dates.size > 10
      Array.new(impression_dates.size, '')
    else
      impression_dates.map{|impression_date| format_date_for_graph(Date.strptime(impression_date))}
    end
  end

  def group_reservations(reservations)
    @grouped_reservations ||= reservations.group_by{|reservation| reservation.created_at.to_date}
  end

  def reservations_for_chart(reservations)
    [group_reservations(reservations).values.map(&:size)]
  end

  def reservations_labels_for_chart(reservations)
    dates = group_reservations(reservations).keys
    if dates.size > 10
      Array.new(dates.size, '')
    else
      dates.map{|reservation_date| format_date_for_graph(reservation_date)}
    end
  end

  def format_date_for_graph(datetime)
    datetime.strftime('%b %d')
  end

  def my_booking_status_info(reservation)
    if reservation.state == 'unconfirmed'
      tooltip("Pending confirmation from host. Booking will expire in #{time_to_expiry(reservation.expiry_time)}.", "<span class='tooltip-spacer'>i</span>".html_safe, {:class => reservation_status_icon(reservation)}, nil)
    else
      content_tag(:i, '', :class => reservation_status_icon(reservation))
    end
  end

  def manage_booking_status_info(reservation)
    if reservation.state == 'unconfirmed'
      tooltip("You must confirm this booking within #{time_to_expiry(reservation.expiry_time)} or it will expire.", "<span class='tooltip-spacer'>i</span>".html_safe, {:class => reservation_status_icon(reservation)}, nil)
    else
      content_tag(:i, '', :class => reservation_status_icon(reservation))
    end
  end
end
