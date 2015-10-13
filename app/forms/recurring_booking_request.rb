class RecurringBookingRequest < Form

  attr_accessor :start_minute, :end_minute, :start_on, :end_on, :schedule_params, :quantity
  attr_accessor :card_number, :card_exp_month, :card_exp_year, :card_code, :card_holder_first_name,
                :card_holder_last_name, :interval, :payment_method_nonce, :total_amount_cents,
                :guest_notes
  attr_reader   :recurring_booking, :listing, :location, :user

  delegate :credit_card_payment?, :manual_payment?, :reservation_type=, :currency,
    :service_fee_amount_host_cents, :service_fee_amount_guest_cents, :billing_authorization,
    :create_billing_authorization, to: :recurring_booking
  delegate :confirm_reservations?, :location, :action_hourly_booking?, :company, to: :listing
  delegate :mobile_number, :mobile_number=, :country_name, :country_name=, :country, to: :user

  validates :listing, :user, :recurring_booking, presence: true
  validates :card_number, :card_exp_month, :card_exp_year, :card_code, :card_holder_first_name,
            :card_holder_last_name, presence: true

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
      @recurring_booking.creator = @listing.creator
      @recurring_booking.interval = interval
      @recurring_booking.guest_notes = guest_notes
      @recurring_booking.start_on = start_on || Date.current
      @recurring_booking.next_charge_date = @recurring_booking.start_on
      @recurring_booking.quantity = [1, quantity.to_i].max
      @recurring_booking.schedule_params = schedule_params
      @recurring_booking.currency = @listing.currency
      @billing_gateway = @instance.payment_gateway(@listing.company.iso_country_code, @recurring_booking.currency)
      @recurring_booking.payment_method = payment_method
      @recurring_booking.subtotal_amount = @recurring_booking.total_amount_calculator.subtotal_amount
      @recurring_booking.service_fee_amount_guest = @recurring_booking.guest_service_fee
      @recurring_booking.service_fee_amount_host = @recurring_booking.host_service_fee
      self.total_amount_cents = @recurring_booking.total_amount.cents
    end


    if @user
      @user.phone_required = true
      @user.phone = @user.mobile_number
      @card_holder_first_name ||= @user.first_name
      @card_holder_last_name ||= @user.last_name
    end

  end

  def process
    valid? && setup_credit_card_customer && errors.empty? && save_reservations
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
                      elsif @billing_gateway.present?
                        Reservation::PAYMENT_METHODS[:credit_card]
                      else
                        Reservation::PAYMENT_METHODS[:manual]
                      end
  end

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      first_name: card_holder_first_name.to_s,
      last_name: card_holder_last_name.to_s,
      number: card_number.to_s,
      month: card_exp_month.to_s,
      year: card_exp_year.to_s,
      verification_value: card_code.to_s
    )
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
      @recurring_booking.payment_gateway = @billing_gateway
      @recurring_booking.payment_method = 'credit_card'
      @recurring_booking.test_mode = @billing_gateway.test_mode?
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
      if credit_card.valid?
        response = @billing_gateway.authorize(self)
        if response
          @token = response
          if (credit_card_id = @billing_gateway.store_credit_card(@recurring_booking.owner, credit_card)).nil?
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
    true
  end

end
