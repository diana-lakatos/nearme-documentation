class RecurringBookingRequest < Form

  attr_accessor :start_minute, :end_minute, :start_on, :end_on, :schedule_params, :quantity,
    :interval, :total_amount_cents, :guest_notes, :total_amount_check
  attr_reader   :recurring_booking, :listing, :location, :user, :payment_subscription

  delegate :currency, :service_fee_amount_host_cents, :service_fee_amount_guest_cents, :billing_authorization,
    :create_billing_authorization, :total_service_amount, :total_amount, to: :recurring_booking
  delegate :confirm_reservations?, :location, :company, to: :listing
  delegate :mobile_number, :mobile_number=, :country_name, :country_name=, :country, to: :user

  validates :listing, :user, :recurring_booking, presence: true
  validate :validate_phone_and_country
  validate :validate_total_amount
  validate :validate_payment_subscription

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
      @recurring_booking.company = @listing.company
      @recurring_booking.currency = @listing.currency
      @recurring_booking.subtotal_amount = @recurring_booking.total_amount_calculator.subtotal_amount
      @recurring_booking.service_fee_amount_guest = @recurring_booking.service_fee_amount_guest
      @recurring_booking.service_fee_amount_host = @recurring_booking.service_fee_amount_host
      self.total_amount_cents = @recurring_booking.total_amount.cents
      @payment_subscription ||= @recurring_booking.build_payment_subscription(payment_subscription_attributes)
    end

    if @user
      @user.phone = @user.mobile_number
      @card_holder_first_name ||= @user.first_name
      @card_holder_last_name ||= @user.last_name
    end

  end

  def process
    valid? && check_overbooking && errors.empty? && save_reservations
  end

  def check_overbooking
    unless confirm_reservations? || @recurring_booking.check_overbooking
      errors.add(:base, @recurring_booking.errors[:base].first)
      return false
    end
    true
  end

  def display_phone_and_country_block?
    !user.has_phone_and_country? || user.phone_or_country_was_changed?
  end

  def action_hourly_booking?
    false
  end

  def payment_subscription_attributes=(psa_attributes)
    @payment_subscription_attributes = psa_attributes
  end

  def payment_subscription_attributes
    (@payment_subscription_attributes || {}).merge(subscriber: @recurring_booking, payer: @user)
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
      @payment_subscription.save
      @payment_subscription.credit_card.save!
      @recurring_booking.save!
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => error
    add_errors(error.record.errors.full_messages)
    false
  end

  def validate_payment_subscription
    if @payment_subscription.blank? || !@payment_subscription.valid?
      errors.add(:base, I18n.t("activemodel.errors.models.reservation_request.attributes.base.payment_invalid"))
    end
  end

  def validate_total_amount
    if @recurring_booking.present? && self.total_amount_check.present? && @recurring_booking.total_amount.cents != self.total_amount_check.to_i
      errors.add(:base, I18n.t("activemodel.errors.models.reservation_request.attributes.base.total_amount_changed"))
    end
  end
end

