require 'money-rails'

module ReservationsHelper
  include CurrencyHelper

  # Return a URL with HTTPS scheme for listing reservation
  def secure_listing_reservations_url(listing, options = {})
    if Rails.env.production?
      options = options.reverse_merge(:protocol => "https://")
    end

    listing_reservations_url(listing, options)
  end

  def location_name(reservation_request)
    reservation_request.location.name
  end

  def form_title(reservation_request)
    "#{reservation_request.quantity} #{reservation_request.listing.name}"
  end

  def reservation_subtotal_price(reservation)
    if reservation.subtotal_amount.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(reservation.subtotal_amount)
    end
  end

  def reservation_service_fee(reservation)
    if reservation.service_fee_amount.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(reservation.service_fee_amount)
    end
  end

  def reservation_total_price(reservation)
    if reservation.total_amount.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(reservation.total_amount)
    end
  end

  def reservation_paid(reservation)
    if reservation.free?
      humanized_money_with_cents_and_symbol(0.0)
    elsif reservation.paid?
      humanized_money_with_cents_and_symbol(reservation.successful_payment_amount)
    else
      reservation.payment_status.titleize
    end
  end
  
  def reservation_status_class(reservation)
    if reservation.confirmed?
      'confirmed'
    elsif reservation.unconfirmed?
      'unconfirmed'
    elsif reservation.cancelled? || reservation.rejected? 
       'cancelled'
    end
  end

  def reservation_status_icon(reservation)
    if reservation.confirmed?
      'ico-check'
    elsif reservation.unconfirmed?
      'ico-pending'
    elsif reservation.cancelled? || reservation.rejected? 
       'ico-close'
    end
  end

  def reservation_balance(reservation)
    humanized_money_with_cents_and_symbol(reservation.balance/100.0)
  end

  def reservation_dates(reservation)
    reservation.periods.map do |period|
      "#{period.date.strftime('%Y-%m-%d')} (#{pluralize(reservation.quantity, 'desk')})"
    end.to_sentence
  end

  def format_reservation_periods(reservation)
    reservation.periods.map do |period|
      date = period.date.strftime('%e %b')
      if reservation.listing.hourly_reservations?
        start_time = minute_of_day_to_time(period.start_minute).strftime("%l:%M%P").strip
        end_time = minute_of_day_to_time(period.end_minute).strftime("%l:%M%P").strip
        ('%s %s&ndash;%s' % [date, start_time, end_time]).html_safe
      else
        date
      end
    end.join(', ')
  end

  def location_query_string(location = @location)
    query = [location.state, location.city, location.country]
    query.reject! { |item| !item.present? || item == "Unknown" }
    query.join('%2C+')
  end

  def minute_of_day_to_time(minute)
    hour = minute/60
    min  = minute%60
    Time.zone.local(Time.zone.today.year, Time.zone.today.month, Time.zone.today.day, hour, min)
  end

  def hourly_summary_for_period(period)
    date = period.date.strftime("%B %e")
    start_time = minute_of_day_to_time(period.start_minute).strftime("%l:%M%P").strip
    end_time = minute_of_day_to_time(period.end_minute).strftime("%l:%M%P").strip

    ('%s %s&ndash;%s (%0.2f hours)' % [date, start_time, end_time, period.hours]).html_safe
  end

  def selected_dates_summary(reservation)
    html_string_array = dates_in_groups_for_reservation(reservation).map do |block|
      if block.size == 1
        period_to_string(block.first)
      else
        period_to_string(block.first) + "&ndash;" + period_to_string(block.last)
      end
    end
    (html_string_array * "<br />").html_safe
  end

  def period_to_string(date)
    date.strftime('%d %b')
  end

  # Group up each of the dates into groups of real contiguous dates.
  #
  # i.e.
  # [[20 Nov 2012, 21 Nov 2012, 22 Nov 2012], [5 Dec 2012], [7 Dec 2012, 8 Dec 2012]]
  def dates_in_groups_for_reservation(reservation)
    reservation.periods.map(&:date).sort.inject([]) { |groups, datetime| 
      date = datetime.to_date
      if groups.last && ((groups.last.last+1.day) == date)
        groups.last << date
      else
        groups << [date]
      end
      groups 
    }
  end

  def reservation_navigation_link(action)
    (link_to(content_tag(:span, action.titleize), self.send("#{action}_reservations_path"), :class => "upcoming-reservations btn btn-medium btn-gray#{action==params[:action] ? " active" : "-darker"}")).html_safe
  end

 def upcoming_reservation_count 
   @upcoming_reservation_count ||= current_user.reservations.not_archived.count
 end

 def archived_reservation_count
    @archived_reservation_count ||= current_user.reservations.archived.count
 end

 def manage_guests_action_column_class(reservation)
   buttons_cnt = (reservation.can_host_cancel? ? 1 : 0) + (reservation.can_confirm? ? 1 : 0) + (reservation.can_reject? ? 1 : 0) 
   "split-#{buttons_cnt}"
 end

end
