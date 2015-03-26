class RecurringBookingRequest < Form

  attr_accessor :start_minute, :end_minute, :start_on, :end_on, :schedule_params, :quantity
  attr_accessor :card_number, :card_exp_month, :card_exp_year, :card_code, :card_holder_first_name,
                :card_holder_last_name, :occurrences
  attr_reader   :recurring_booking, :listing, :location, :user

  def_delegators :@recurring_booking, :credit_card_payment?, :manual_payment?, :reservation_type=
  def_delegators :@listing,     :confirm_reservations?, :location, :action_hourly_booking?
  def_delegators :@user,        :mobile_number, :mobile_number=, :country_name, :country_name=, :country

  before_validation :setup_credit_card_customer, :if => lambda { recurring_booking.try(:reservations).try(:first) and user and user.valid?}

  validates :listing,     :presence => true
  validates :recurring_booking, :presence => true
  validates :user,        :presence => true

  validate :validate_phone_and_country

  def initialize(listing, user, platform_context, attributes = {})
    @user = user
    @listing = listing
    @instance = platform_context.instance

    # We need to store additional_charge_ids to pass it to reservations
    @additional_charge_ids = attributes.delete(:additional_charge_ids)
    store_attributes(attributes)

    if @listing
      @recurring_booking = @listing.recurring_bookings.build
      @recurring_booking.owner = user
      @recurring_booking.start_minute = start_minute.to_i if @listing.action_hourly_booking?
      @recurring_booking.end_minute = end_minute.to_i if @listing.action_hourly_booking?
      @recurring_booking.start_on = start_on || Date.current
      @recurring_booking.end_on = end_on
      @recurring_booking.occurrences = occurrences.to_i - 1 <= 0 ? 49 : [occurrences.to_i - 1, 49].min
      @recurring_booking.quantity = [1, quantity.to_i].max
      @recurring_booking.schedule_params = schedule_params
      @recurring_booking.currency = @listing.currency
      @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, @recurring_booking.currency, @listing.company.iso_country_code) if @user
      @recurring_booking.payment_method = payment_method
      @count = 0
      @recurring_booking.schedule.occurrences(@recurring_booking.end_on || Time.zone.now + 20.years)[0..@recurring_booking.occurrences].each do |date|
        @reservation = @recurring_booking.reservations.build
        @reservation.listing = @listing
        @reservation.reservation_type = @listing.action_hourly_booking ? 'hourly' : 'daily'
        @reservation.currency = @listing.currency
        @reservation.add_period(date, @recurring_booking.start_minute, @recurring_booking.end_minute)
        @reservation.payment_method = @recurring_booking.payment_method
        @reservation.quantity = @recurring_booking.quantity
        @reservation.user = user
        @reservation.additional_charges << get_additional_charges
        @reservation = @reservation.decorate
        @last_date = date
        @count += 1
      end
      @recurring_booking.end_on ||= @last_date
      @recurring_booking.occurrences ||= @count
      @recurring_booking.service_fee_amount_guest_cents = @reservation.try(:service_fee_amount_guest_cents)
      @recurring_booking.service_fee_amount_host_cents = @reservation.try(:service_fee_amount_host_cents)
      @recurring_booking.subtotal_amount_cents = @reservation.try(:subtotal_amount_cents)

    end

    if @user
      @user.phone_required = true
      @user.phone = @user.mobile_number
      @card_holder_first_name ||= @user.first_name
      @card_holder_last_name ||= @user.last_name
    end

  end

  def process
    valid? && save_reservations
  end

  def display_phone_and_country_block?
    !user.has_phone_and_country? || user.phone_or_country_was_changed?
  end

  def reservation_periods
    @recurring_booking.schedule.occurrences(@recurring_booking.end_on)[0..49]
  end

  def payment_method
    @payment_method = if @listing.action_free_booking?
                        Reservation::PAYMENT_METHODS[:free]
                      elsif @billing_gateway.try(:possible?)
                        Reservation::PAYMENT_METHODS[:credit_card]
                      else
                        Reservation::PAYMENT_METHODS[:manual]
                      end
  end

  def dates
    @recurring_booking.reservations.map { |r| r.periods.map(&:date) }.flatten
  end

  private

  def get_additional_charges
    AdditionalChargeType.get_mandatory_and_optional_charges(@additional_charge_ids).pluck(:id).map do |id|
      AdditionalCharge.new(
        additional_charge_type_id: id,
        currency: @reservation.currency
      )
    end
  end

  def validate_phone_and_country
    add_error("Please complete the contact details", :contact_info) unless user_has_mobile_phone_and_country?
  end

  def user_has_mobile_phone_and_country?
    user && user.country_name.present? && user.mobile_number.present?
  end

  def save_reservations
    User.transaction do
      user.save!
      @charged = false
      @recurring_booking.reservations.each do |reservation|
        if reservation.valid?
          if !reservation.listing.action_free_booking? && reservation.payment_method == Reservation::PAYMENT_METHODS[:credit_card] && !@charged
            mode = @instance.test_mode? ? "test" : "live"
            reservation.build_billing_authorization(
              token: @token,
              payment_gateway_class: @gateway_class,
              payment_gateway_mode: mode
            )
            @charged = true
          end
          reservation.credit_card_id = @recurring_booking.credit_card_id
        else
          @recurring_booking.reservations = @recurring_booking.reservations - [reservation]
        end
      end
      @recurring_booking.save!
    end
  rescue ActiveRecord::RecordInvalid => error
    add_errors(error.record.errors.full_messages)
    false
  end

  def setup_credit_card_customer
    clear_errors(:cc)
    return true unless using_credit_card?

    begin
      credit_card = ActiveMerchant::Billing::CreditCard.new(
        first_name: card_holder_first_name.to_s,
        last_name: card_holder_last_name.to_s,
        number: card_number.to_s,
        month: card_exp_month.to_s,
        year: card_exp_year.to_s,
        verification_value: card_code.to_s
      )

      if credit_card.valid?
        response = @billing_gateway.authorize(@reservation.total_amount_cents, credit_card)
        if response[:error].present?
          add_error(response[:error], :cc)
        else
          @token = response[:token]
          @gateway_class = response[:payment_gateway_class]
          if (credit_card_id = @billing_gateway.store_credit_card(@reservation.owner, credit_card)).nil?
            add_error("Unfortunately we have some internal issues with processing your credit card. There is nothing you can do, changing credit card will not help. Please try again later", :cc)
          else
            @recurring_booking.credit_card_id = credit_card_id
          end
        end
      else
        add_error("Those credit card details don't look valid", :cc)
      end
    rescue Billing::Error => e
      add_error(e.message, :cc)
    end
  end

  def using_credit_card?
    @reservation.try(:credit_card_payment?)
  end

end
