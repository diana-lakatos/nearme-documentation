class ReservationDecorator < Draper::Decorator
  include CurrencyHelper
  include TooltipHelper

  delegate_all

  def days
    periods.size
  end

  def days_in_words
    I18n.t('day', count: days).titleize
  end

  def selected_dates_summary(separator = "<br />")
    items = dates_in_groups.map do |block|
      content = if block.size == 1
               period_to_string(block.first)
             else
               period_to_string(block.first) + " &ndash; " + period_to_string(block.last)
             end
      "<p>#{content}</p>".html_safe
    end
    items.join(separator).html_safe
  end

  def hourly_summary_for_first_period(show_date = true)
    reservation_period = periods.first.decorate
    reservation_period.hourly_summary(show_date)
  end

  def subtotal_price
    if subtotal_amount.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(subtotal_amount)
    end
  end

  def service_fee
    if service_fee_amount.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(service_fee_amount)
    end
  end

  def total_price
    if total_amount.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(total_amount)
    end
  end

  def paid
    if free?
      humanized_money_with_cents_and_symbol(0.0)
    elsif paid?
      humanized_money_with_cents_and_symbol(successful_payment_amount)
    else
      payment_status.titleize
    end
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

  def manage_guests_action_column_class
    buttons_count = [can_host_cancel?, can_confirm?, can_reject?].count(true)
    "split-#{buttons_count}"
  end

  def short_dates
    first = date.strftime('%-e %b')
    last = last_date.strftime('%-e %b')

    first == last ? first : "#{first}-#{last}"
  end

  def format_reservation_periods
    periods.map do |period|
      period = period.decorate
      date = period.date.strftime('%-e %b')
      if listing.hourly_reservations?
        start_time = period.start_minute_of_day_to_time.strftime("%l:%M%P").strip
        end_time = period.end_minute_of_day_to_time.strftime("%l:%M%P").strip
        ('%s %s&ndash;%s' % [date, start_time, end_time]).html_safe
      else
        date
      end
    end.join(', ')
  end

  def my_booking_status_info
    if state == 'unconfirmed'
      tooltip_text = "Pending confirmation from host. Booking will expire in #{time_to_expiry(expiry_time)}."
      link_text = "<span class='tooltip-spacer'>i</span>".html_safe

      tooltip(tooltip_text, link_text, {class: status_icon}, nil)
    else
      "<i class='#{status_icon}'></i>".html_safe
    end
  end

  def manage_booking_status_info
    if state == 'unconfirmed'
      tooltip_text = "You must confirm this booking within #{time_to_expiry(expiry_time)} or it will expire."
      link_text = "<span class='tooltip-spacer'>i</span>".html_safe

      tooltip(tooltip_text, link_text, {class: status_icon}, nil)
    else
      "<i class='#{status_icon}'></i>".html_safe
    end
  end

  private

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
