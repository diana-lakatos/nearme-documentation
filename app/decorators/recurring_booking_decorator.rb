class RecurringBookingDecorator < OrderDecorator
  include Draper::LazyHelpers

  include CurrencyHelper
  include TooltipHelper

  def with_payment?
    false
  end

  def with_payment_subscription?
    true
  end

  # @return [String] empty string
  def total_units_text
    ''
  end

  def payment_state
    if recurring_booking_periods.any?
      recurring_booking_periods.first.payment.state.capitalize
    else
      payment_subscription.present? ? 'Authorized' : 'Missing'
    end
  end

  def interval
    object.transactable_pricing.units_to_s
  end

  delegate_all

  def days
    periods.size
  end

  def total_price_host
    if subtotal_amount.to_f.zero?
      'Free!'
    else
      render_money(total_payable_to_host)
    end
  end

  # @return [String] total amount payable to host formatted using the global
  #   currency formatting rules
  def total_payable_to_host_formatted
    render_money(total_payable_to_host)
  end

  def total_price_for_guest
    if subtotal_amount.to_f.zero?
      'Free!'
    else
      render_money(total_amount)
    end
  end

  def total_price_for(current_user)
    if total_amount.to_f.zero?
      'Free!'
    else
      current_user == recurring_booking.host ? total_price_host : total_price_for_guest
    end
  end

  def service_fee_guest
    if service_fee_amount_guest.to_f.zero?
      'Free!'
    else
      render_money(service_fee_amount_guest)
    end
  end

  # @return [String] total price for this recurring booking order rendered according to
  #   the global currency rendering rules, or 'Free!' if free
  def total_price(_current_user = nil)
    if total_amount.to_f.zero?
      'Free!'
    else
      render_money(total_amount)
    end
  end

  # @return [String] last unpaid amount for this recurring booking rendered according
  #   to the global currency rendering rules
  def last_unpaid_amount
    render_money(recurring_booking_periods.unpaid.last.try(:total_amount))
  end

  def selected_dates_summary(options = {})
    wrapper = options[:wrapper].presence || :p
    separator = options[:separator].presence || :br
    separator = separator.is_a?(Symbol) ? h.tag(separator) : separator

    items = dates_in_groups.map do |block|
      content = if block.size == 1
                  period_to_string(block.first)
                else
                  period_to_string(block.first) + ' &ndash; ' + period_to_string(block.last)
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
    render_money(balance / 100.0)
  end

  def dates
    periods.map do |period|
      "#{I18n.l(period.date.to_date, format: :short)} (#{'desk'.pluralize(quantity)})"
    end.to_sentence
  end

  def dates_to_array(for_reservations = nil)
    for_reservations ||= reservations
    for_reservations.map { |r| r.periods.map { |p| I18n.l(p.date.to_date, format: :short).to_s } }.flatten
  end

  def manage_guests_action_column_class
    buttons_count = [can_host_cancel?, can_confirm?, can_reject?].size(true)
    "split-#{buttons_count}"
  end

  def short_dates
    first = I18n.l(start_on.to_date, format: :long)
    last = I18n.l(end_on.to_date, format: :long)

    first == last ? first : "#{first} - #{last}"
  end
  alias long_dates short_dates

  def format_reservation_periods
    periods.map do |period|
      period = period.decorate
      date = I18n.l(period.date.to_date, format: :long)

      if transactable.action_hourly_booking?
        start_time = I18n.l(period.start_minute_of_day_to_time, format: :short)
        end_time = I18n.l(period.end_minute_of_day_to_time, format: :short)
        ('%s %s&ndash;%s' % [date, start_time, end_time]).html_safe
      else
        date
      end
    end.join(', ')
  end

  def my_booking_status_info
    status_info("Pending confirmation from host. Booking will expire in #{time_to_expiry(expires_at)}.")
  end

  def my_booking_status_info_new
    raw("Pending confirmation from host. Booking will expire in <strong>#{time_to_expiry(expires_at)}</strong>.")
  end

  # @return [String] formatted string instructing the user to confirm their booking before expiration if unconfirmed, otherwise
  #   renders an icon with the status information
  def manage_booking_status_info
    status_info("You must confirm this booking within #{time_to_expiry(expires_at)} or it will expire.")
  end

  # @return [String] formatted string instructing the user to confirm their booking before expiration
  def manage_booking_status_info_new
    raw("You must confirm this booking within <strong>#{time_to_expiry(expires_at)}</strong> or it will expire.")
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.listing.name, user_message.thread_context.listing.decorate.show_path
  end

  def state_to_string
    return 'declined' if rejected?
    state.split('_').first
  end

  def hourly_summary(show_date = false)
    start_time = I18n.l(starts_at, format: :short)
    end_time = I18n.l(ends_at, format: :short)

    if show_date
      formatted_start_date = I18n.l(starts_at, format: :long)
      formatted_end_date = I18n.l(ends_at, format: :long)
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
    minute_of_day_to_time(start_minute.to_i)
  end

  def end_minute_of_day_to_time
    minute_of_day_to_time(end_minute.to_i)
  end

  def time_to_expiry(time_of_event)
    current_time = Time.zone.now
    total_seconds = time_of_event - current_time
    hours = (total_seconds / 1.hour).floor
    minutes = ((total_seconds - hours.hours) / 1.minute).floor
    if hours < 1 && minutes < 1
      'less than minute'
    else
      if hours < 1
        '%d minutes' % [minutes]
      else
        '%d hours, %d minutes' % [hours, minutes]
      end
    end
  end

  private

  def status_info(text)
    if state == 'unconfirmed'
      tooltip(text, "<span class='tooltip-spacer'>i</span>".html_safe, { class: status_icon }, nil)
    else
      "<i class='#{status_icon}'></i>".html_safe
    end
  end

  # [[20 Nov 2012, 21 Nov 2012, 22 Nov 2012], [5 Dec 2012], [7 Dec 2012, 8 Dec 2012]]
  def dates_in_groups
    periods.map(&:date).sort.each_with_object([]) do |datetime, groups|
      date = datetime.to_date
      if groups.last && ((groups.last.last + 1.day) == date)
        groups.last << date
      else
        groups << [date]
      end
      groups
    end
  end

  def period_to_string(date)
    I18n.l(date.to_date, format: :long)
  end
end
