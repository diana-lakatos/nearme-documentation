# frozen_string_literal: true
class ReservationDecorator < OrderDecorator
  include CurrencyHelper
  include TooltipHelper
  include FeedbackDecoratorHelper
  include Rails.application.routes.url_helpers

  delegate_all

  delegate :days_in_words, :nights_in_words, :selected_dates_summary, :dates_in_groups, :period_to_string, to: :date_presenter

  def with_payment?
    true
  end

  def with_payment_subscription?
    false
  end

  def days
    periods.size
  end

  def hourly_summary_for_first_period(show_date = true)
    reservation_period = periods.first.decorate
    reservation_period.hourly_summary(show_date, event_booking: transactable.event_booking?)
  end

  def total_cost
    render_money(total_amount_cents)
  end

  def periods_cost
    periods.map { |p| p.hours * unit_price }.sum
  end

  def additional_charges_cost
    additional_charges.map(&:amount).sum
  end

  def unit_price_with_currency
    render_money(unit_price)
  end

  # @return [String] subtotal price formatted using the global currency formatting rules
  #   or 'Free!' if free
  def subtotal_price
    if subtotal_amount.to_f.zero?
      'Free!'
    else
      render_money(subtotal_amount)
    end
  end

  # @return [String] service fee (guest part) formatted using the global currency formatting
  #   rules or 'Free!' if free
  def service_fee_guest
    if service_fee_amount_guest.to_f.zero?
      'Free!'
    else
      render_money(service_fee_amount_guest)
    end
  end

  # @return [String] total tax amount for this reservation formatted using the global
  #   currency formatting rules
  def tax_price
    render_money(total_tax_amount) if total_tax_amount && total_tax_amount > 0
  end

  # @return [String] total price formatted using the global currency formatting rules
  #   or 'Free!' if free
  def total_price
    if total_amount.to_f.zero?
      'Free!'
    else
      render_money(total_amount)
    end
  end

  # @return [String] total amount payable to host formatted using the global currency
  #   formatting rules
  def total_payable_to_host_formatted
    render_money(total_payable_to_host)
  end

  # @return [String] amount paid for this reservation formatted using the global currency
  #   formatting rules or the current state of the payment if not yet paid
  def paid
    if is_free?
      render_money(0.0)
    elsif paid?
      render_money(payment.amount)
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
    render_money(balance / 100.0)
  end

  def dates_to_array
    periods.map do |period|
      I18n.l(period.date.to_date, :long).to_s
    end
  end

  def manage_guests_action_column_class
    buttons_count = [can_host_cancel?, can_confirm?, can_reject?].select { |button| button }
    "split-#{buttons_count.size}"
  end

  def short_dates
    first = I18n.l(date, format: :day_and_month)
    last = I18n.l(date, format: :day_and_month)

    first == last ? first : "#{first} - #{last}"
  end

  # @return [String] summary of selected dates for this reservation
  def long_dates
    date_presenter.selected_dates_summary_no_html(:short)
  end

  # @return [String] total units text (e.g. "1 day", "3 nights")
  def total_units_text
    unit = transactable_pricing.try(:night_booking?) ? 'general.night' : 'general.day'
    [total_units, I18n.t(unit, count: reservation.total_units)].join(' ')
  end

  def format_reservation_periods
    periods.map do |period|
      period = period.decorate
      date = I18n.l(period.date.to_date, format: :day_and_month)
      if transactable.event_booking?
        ('%s %s' % [date, start_time]).html_safe
      elsif transactable_pricing.hour_booking?
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

  # @return [String] formatted string instructing the user to confirm their booking before expiration if unconfirmed, otherwise
  #   renders an icon with the status information
  def manage_booking_status_info
    status_info("You must confirm this booking within #{time_to_expiry(expires_at)} or it will expire.")
  end

  # @return [String] formatted string instructing the user to confirm their booking before expiration
  #   using the translation key 'dashboard.host_reservations.pending_confirmation'
  def manage_booking_status_info_new
    I18n.t('dashboard.host_reservations.pending_confirmation', time_to_expiry: time_to_expiry(expires_at)).html_safe
  end

  def next_payment_transfer
    I18n.l(PaymentTransfers::SchedulerMethods.new(instance).next_payment_transfers_date, format: :long)
  end

  def user_message_summary(user_message)
    if user_message.thread_context.present? && user_message.thread_context.listing.present? && user_message.thread_context.location
      h.link_to user_message.thread_context.name, user_message.thread_context.listing.decorate.show_path
    else
      '[Deleted]'
    end
  end

  # @return [String] state of the reservation in a human readable format
  def state_to_string
    return 'declined' if rejected?
    state.split('_').first
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

  def feedback_object
    object
  end

  private

  def status_info(text)
    if state == 'unconfirmed'
      tooltip(text, "<span class='tooltip-spacer'>i</span>".html_safe, { class: status_icon }, nil)
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
