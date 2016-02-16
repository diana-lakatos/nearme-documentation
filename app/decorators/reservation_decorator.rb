class ReservationDecorator < Draper::Decorator

  include CurrencyHelper
  include TooltipHelper
  include FeedbackDecoratorHelper
  include Rails.application.routes.url_helpers

  delegate_all

  delegate :days_in_words, :nights_in_words, :selected_dates_summary, :dates_in_groups, :period_to_string, to: :date_presenter

  def days
    periods.size
  end

  def hourly_summary_for_first_period(show_date = true)
    reservation_period = periods.first.decorate
    reservation_period.hourly_summary(show_date, { schedule_booking: listing.schedule_booking? })
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

  def total_price
    if total_amount.to_f.zero?
      "Free!"
    else
      humanized_money_with_cents_and_symbol(total_amount)
    end
  end

  def total_payable_to_host_formatted
    humanized_money_with_cents_and_symbol(total_payable_to_host)
  end

  def paid
    if is_free?
      humanized_money_with_cents_and_symbol(0.0)
    elsif paid?
      humanized_money_with_cents_and_symbol(successful_payment_amount)
    else
      payment.state.titleize
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

  def dates_to_array
    periods.map do |period|
      "#{I18n.l(period.date.to_date, :long)}"
    end
  end

  def manage_guests_action_column_class
    buttons_count = [can_host_cancel?, can_confirm?, can_reject?].count(true)
    "split-#{buttons_count}"
  end

  def short_dates
    first = I18n.l(date, format: :day_and_month)
    last = I18n.l(date, format: :day_and_month)

    first == last ? first : "#{first} - #{last}"
  end

  def long_dates
    date_presenter.selected_dates_summary_no_html(:short)
  end

  def total_units_text
    unit = listing.overnight_booking? ? 'general.night' : 'general.day'
    [total_units, I18n.t(unit, count: reservation.total_units)].join(' ')
  end

  def format_reservation_periods
    periods.map do |period|
      period = period.decorate
      date = I18n.l(period.date.to_date, format: :day_and_month)
      if listing.schedule_booking?
        ('%s %s' % [date, start_time]).html_safe
      elsif listing.action_hourly_booking?
        start_time = I18n.l(period.start_minute_of_day_to_time, format: :short)
        end_time = I18n.l(period.end_minute_of_day_to_time, format: :short)
        ('%s %s&ndash;%s' % [date, start_time, end_time]).html_safe
      else
        date
      end
    end.join(', ')
  end

  def my_booking_status_info
    status_info("Pending confirmation from host. Booking will expire in #{time_to_expiry(expire_at)}.")
  end

  def manage_booking_status_info
    status_info("You must confirm this booking within #{time_to_expiry(expire_at)} or it will expire.")
  end

  def manage_booking_status_info_new
    I18n.t('dashboard.host_reservations.pending_confirmation', time_to_expiry: time_to_expiry(expire_at)).html_safe
  end

  def next_payment_transfer
    I18n.l(PaymentTransfers::SchedulerMethods.new(instance).next_payment_transfers_date, format: :long)
  end

  def user_message_recipient
    owner
  end

  def user_message_summary(user_message)
    if user_message.thread_context.present? && user_message.thread_context.listing.present? && user_message.thread_context.location
      h.link_to user_message.thread_context.name, location_path(user_message.thread_context.location, user_message.thread_context.listing)
    else
      "[Deleted]"
    end
  end

  def state_to_string
    return 'declined' if rejected?
    state.split('_').first
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

  def feedback_object
    object
  end

  private

  def status_info(text)
    if state == 'unconfirmed'
      tooltip(text, "<span class='tooltip-spacer'>i</span>".html_safe, {class: status_icon}, nil)
    else
      "<i class='#{status_icon}'></i>".html_safe
    end
  end

  def date_presenter
    @date_presenter ||= DatePresenter.new(periods.map(&:date))
  end

  def service_fee_calculator
    object.send(:service_fee_calculator)
  end

end
