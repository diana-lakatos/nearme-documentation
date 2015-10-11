class RecurringBookingDecorator < Draper::Decorator
  include Draper::LazyHelpers

  include CurrencyHelper
  include TooltipHelper

  delegate_all

  def days
    periods.size
  end

  def subtotal_price
    if subtotal_amount.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(subtotal_amount)
    end
  end

  def service_fee_guest
    if service_fee_amount_guest.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(service_fee_amount_guest)
    end
  end

  def total_price(current_user = nil)
    if total_amount.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(total_amount)
    end
  end

  def last_unpaid_amount
    humanized_money_with_cents_and_symbol recurring_booking_periods.where(paid_at: nil).last.try(:monetized_total_amount)
  end

  def selected_dates_summary(options = {})
    wrapper = options[:wrapper].presence || :p
    separator = options[:separator].presence || :br
    separator = separator.is_a?(Symbol) ? h.tag(separator) : separator

    items = dates_in_groups.map do |block|
      content = if block.size == 1
               period_to_string(block.first)
             else
               period_to_string(block.first) + " &ndash; " + period_to_string(block.last)
             end
      h.content_tag(wrapper, content.html_safe)
    end
    items.join(separator).html_safe
  end

  def hourly_summary_for_first_period(show_date = true)
    reservation_period = periods.first.decorate
    reservation_period.hourly_summary(show_date)
  end

  def status_class
    if confirmed?
      'confirmed'
    elsif unconfirmed?
      'unconfirmed'
    elsif cancelled? || rejected?
      'cancelled'
    end
  end

  def status_icon
    if confirmed?
      'ico-check'
    elsif unconfirmed?
      'ico-pending'
    elsif cancelled? || rejected?
      'ico-close'
    elsif expired?
      'ico-time'
    end
  end

  def formatted_balance
    humanized_money_with_cents_and_symbol(balance/100.0)
  end

  def dates
    periods.map do |period|
      "#{period.date.strftime('%Y-%m-%d')} (#{'desk'.pluralize(quantity)})"
    end.to_sentence
  end

  def dates_to_array(for_reservations = nil)
    for_reservations ||= reservations
    for_reservations.map { |r| r.periods.map { |p| "#{p.date.strftime('%Y-%m-%d')}" } }.flatten
  end

  def manage_guests_action_column_class
    buttons_count = [can_host_cancel?, can_confirm?, can_reject?].count(true)
    "split-#{buttons_count}"
  end

  def short_dates
    first = start_on.strftime('%-e %b %Y')
    last = end_on.strftime('%-e %b %Y')

    first == last ? first : "#{first} - #{last}"
  end

  def long_dates
    first = start_on.strftime('%-e %b, %Y')
    last = end_on.try(:strftime, '%-e %b, %Y')

    first == last ? first : "#{first} - #{last}"
  end

  def format_reservation_periods
    periods.map do |period|
      period = period.decorate
      date = period.date.strftime('%-e %b %Y')
      if listing.action_hourly_booking?
        start_time = period.start_minute_of_day_to_time.strftime("%l:%M%P").strip
        end_time = period.end_minute_of_day_to_time.strftime("%l:%M%P").strip
        ('%s %s&ndash;%s' % [date, start_time, end_time]).html_safe
      else
        date
      end
    end.join(', ')
  end

  def my_booking_status_info
    status_info("Pending confirmation from host. Booking will expire in #{time_to_expiry(expiry_time)}.")
  end

  def my_booking_status_info_new
    raw("Pending confirmation from host. Booking will expire in <strong>#{time_to_expiry(expiry_time)}</strong>.")
  end

  def manage_booking_status_info
    status_info("You must confirm this booking within #{time_to_expiry(expiry_time)} or it will expire.")
  end

  def manage_booking_status_info_new
    raw("You must confirm this booking within <strong>#{time_to_expiry(expiry_time)}</strong> or it will expire.")
  end

  def user_message_recipient
    owner
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.listing.name, location_path(user_message.thread_context.location, user_message.thread_context.listing)
  end

  def state_to_string
    return 'declined' if rejected?
    state.split('_').first
  end

  def hourly_summary(show_date = false)
    start_time = start_minute_of_day_to_time.strftime("%l:%M").strip
    end_time = end_minute_of_day_to_time.strftime("%l:%M%P").strip
    start_time_suffix = start_minute_of_day_to_time.strftime("%P").strip
    end_time_suffix = end_minute_of_day_to_time.strftime("%P").strip

    start_time += start_time_suffix unless start_time_suffix == end_time_suffix

    if show_date
      formatted_start_date = start_on.strftime("%B %-e %Y")
      formatted_end_date = end_on.strftime("%B %-e %Y")
      ('%s&ndash;%s %s&ndash;%s (%0.2f hours)' % [formatted_start_date, formatted_end_date, start_time, end_time, hours]).html_safe
    else
      ('%s&ndash;%s<br />(%0.2f hours)' % [start_time, end_time, hours]).html_safe
    end
  end

  def minute_of_day_to_time(minute)
    hour = minute / 60
    min  = minute % 60
    Time.zone.local(Time.zone.today.year, Time.zone.today.month, Time.zone.today.day, hour, min)
  end

  def start_minute_of_day_to_time
    minute_of_day_to_time(start_minute)
  end

  def end_minute_of_day_to_time
    minute_of_day_to_time(end_minute)
  end

  private

  def status_info(text)
    if state == 'unconfirmed'
      tooltip(text, "<span class='tooltip-spacer'>i</span>".html_safe, {class: status_icon}, nil)
    else
      "<i class='#{status_icon}'></i>".html_safe
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

  # [[20 Nov 2012, 21 Nov 2012, 22 Nov 2012], [5 Dec 2012], [7 Dec 2012, 8 Dec 2012]]
  def dates_in_groups
    periods.map(&:date).sort.inject([]) { |groups, datetime|
      date = datetime.to_date
      if groups.last && ((groups.last.last+1.day) == date)
        groups.last << date
      else
        groups << [date]
      end
      groups
    }
  end

  def period_to_string(date)
    date.strftime('%A, %B %-e')
  end

end
