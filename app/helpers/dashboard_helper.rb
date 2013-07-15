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
    current_time = Time.now.utc
    total_seconds = time_of_event - current_time
    hours = (total_seconds/1.hour).floor
    minutes = ((total_seconds-hours.hours)/1.minute).floor
    if hours < 1 and minutes < 1
      'less than minute'
    else
      '%02d:%02d' % [hours, minutes]
    end
  end

  def manage_guests_time_to_expiry(reservation)
    if reservation.state == 'unconfirmed'
      expiry_time = reservation.expiry_time
      "Booking expires in #{time_to_expiry(expiry_time)}"
    end
  end

  def guest_filter_class(guest_list, filter)
    'inactive' unless guest_list.state == filter
  end

  def periods_dates(periods)
    periods.map(&:date).map{ |date| date.to_s(:db) }
  end

  def group_charges(charges)
    @grouped_charges ||= charges.group_by do |c|
      c.currency
    end.tap do |charges_grouped_by_currency| 
      charges_grouped_by_currency.each do |currency, charges_in_the_same_currency|
        charges_grouped_by_currency[currency] = charges_in_the_same_currency.group_by do |c|
          format_charge_date_for_graph(c.created_at)
        end.inject({}) do |arr, (k, v)|
          # later on we might want to make sure that all prices are in the same currency
          arr[k] = v.sum(&:price)
        arr
        end
      end
    end
  end

  def values_for_chart(charges)
    grouped_values = group_charges(charges)
    grouped_values.inject([]) do |all_values, (currency, charges_by_date)|
      all_values << labels_for_chart.inject([]) do |values, date|
      values << (charges_by_date[date].to_f.zero? ? 0 : charges_by_date[date].amount )
      values
      end
      all_values
    end
  end

  def labels_for_chart
    @labels_for_chart ||= [].tap do |arr|
      (0..6).each { |i| arr << format_charge_date_for_graph(Time.zone.today - i.day) }
    end.sort
  end


  def format_charge_date_for_graph(date)
    date.to_date.strftime('%b %d')
  end
end
