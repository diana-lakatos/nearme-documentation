module DashboardHelper

  def in_new_listing?
    (params[:action] == 'new' || params[:action] == 'edit') && params[:controller].include?('listings') && params[:id].blank?
  end

  def in_new_or_edit?
    ['new', 'create', 'edit', 'update'].include?(params[:action])
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
  
  def my_booking_status_info(reservation)
    reservation = reservation.decorate
    if reservation.state == 'unconfirmed'
      tooltip("Pending confirmation from host. Booking will expire in #{time_to_expiry(reservation.expiry_time)}.", "<span class='tooltip-spacer'>i</span>".html_safe, {:class => reservation.status_icon}, nil)
    else
      content_tag(:i, '', :class => reservation.status_icon)
    end
  end

  def manage_booking_status_info(reservation)
    reservation = reservation.decorate
    if reservation.state == 'unconfirmed'
      tooltip("You must confirm this booking within #{time_to_expiry(reservation.expiry_time)} or it will expire.", "<span class='tooltip-spacer'>i</span>".html_safe, {:class => reservation.status_icon}, nil)
    else
      content_tag(:i, '', :class => reservation.status_icon)
    end
  end

  def no_reservations_info_for_state(state)
    case state.to_s
    when 'unconfirmed'
      'You have no unconfirmed reservations. Have a nice day!'
    when 'confirmed'
      "You haven't confirmed any reservations yet."
    when 'archived'
      "You don't have any archived reservations."
    end
  end
end
