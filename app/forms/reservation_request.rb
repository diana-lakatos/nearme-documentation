class ReservationRequest < Form

  attr_accessor :dates, :start_minute, :end_minute
  attr_accessor :card_number, :card_expires, :card_code, :card_holder_first_name, :card_holder_last_name
  attr_accessor :waiver_agreement_templates
  attr_reader   :reservation, :listing, :location, :user

  def_delegators :@reservation, :quantity, :quantity=
  def_delegators :@reservation, :credit_card_payment?, :manual_payment?, :remote_payment?
  def_delegators :@listing,     :confirm_reservations?, :hourly_reservations?, :location
  def_delegators :@user,        :mobile_number, :mobile_number=, :country_name, :country_name=, :country

  before_validation :setup_credit_card_customer, :if => lambda { reservation and user and user.valid?}

  validates :listing,     :presence => true
  validates :reservation, :presence => true
  validates :user,        :presence => true

  validate :validate_phone_and_country
  validate :waiver_agreements_accepted

  def initialize(listing, user, platform_context, attributes = {})
    @listing = listing
    @waiver_agreement_templates = []
    @user = user
    if @listing
      @reservation = listing.reservations.build
      @instance = platform_context.instance
      @reservation.currency = @listing.currency
      @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, @reservation.currency) if @user
      @reservation.payment_method = payment_method
      @reservation.user = user
      @reservation = @reservation.decorate
    end

    store_attributes(attributes)

    if @user
      @user.phone_required = true
      @user.phone = @user.mobile_number
      @card_holder_first_name ||= @user.first_name
      @card_holder_last_name ||= @user.last_name
    end

    if @listing
      if @listing.hourly_reservations?
        @start_minute = start_minute.try(:to_i)
        @end_minute = end_minute.try(:to_i)
      else
        @start_minute = nil
        @end_minute   = nil
      end

      @dates = @dates.split(',') if @dates.is_a?(String)
      @dates.each do |date_string|
        @reservation.add_period(Date.parse(date_string), start_minute, end_minute)
      end
    end

  end

  def process
    valid? && save_reservation
  end

  def display_phone_and_country_block?
    !user.has_phone_and_country? || user.phone_or_country_was_changed?
  end

  def reservation_periods
    reservation.periods
  end

  def payment_method
    @payment_method = if @reservation.listing.free?
                        Reservation::PAYMENT_METHODS[:free]
                      elsif @billing_gateway.try(:possible?) && @billing_gateway.try(:remote?)
                        Reservation::PAYMENT_METHODS[:remote]
                      elsif @billing_gateway.try(:possible?)
                        Reservation::PAYMENT_METHODS[:credit_card]
                      else
                        Reservation::PAYMENT_METHODS[:manual]
                      end
  end

  private

  def validate_phone_and_country
    add_error("Please complete the contact details", :contact_info) unless user_has_mobile_phone_and_country?
  end

  def user_has_mobile_phone_and_country?
    user && user.country_name.present? && user.mobile_number.present?
  end

  def save_reservation
    User.transaction do
      user.save!
      if !reservation.listing.free? && @payment_method == Reservation::PAYMENT_METHODS[:credit_card]
        mode = @instance.test_mode? ? "test" : "live"
        reservation.build_billing_authorization(
          token: @token,
          payment_gateway_class: @gateway_class,
          payment_gateway_mode: mode
        )
        if reservation.listing.transactable_type.cancellation_policy_enabled.present?
          reservation.cancellation_policy_hours_for_cancellation = reservation.listing.transactable_type.cancellation_policy_hours_for_cancellation
          reservation.cancellation_policy_penalty_percentage = reservation.listing.transactable_type.cancellation_policy_penalty_percentage
        end
      end
      reservation.save!
    end
  rescue ActiveRecord::RecordInvalid => error
    add_errors(error.record.errors.full_messages)
    false
  end

  def setup_credit_card_customer
    clear_errors(:cc)
    return true unless using_credit_card?

    begin
      self.card_expires = card_expires.to_s.strip

      credit_card = ActiveMerchant::Billing::CreditCard.new(
        first_name: card_holder_first_name.to_s,
        last_name: card_holder_last_name.to_s,
        number: card_number.to_s,
        month: card_expires.to_s[0,2],
        year: card_expires.to_s[-4,4],
        verification_value: card_code.to_s
      )

      if credit_card.valid?
        response = @billing_gateway.authorize(@reservation.total_amount_cents, credit_card)
        if response[:error].present?
          add_error(response[:error], :cc)
        else
          @token = response[:token]
          @gateway_class = response[:payment_gateway_class]
        end
      else
        add_error("Those credit card details don't look valid", :cc)
      end
    rescue Billing::Error => e
      add_error(e.message, :cc)
    end
  end

  def using_credit_card?
    reservation.credit_card_payment?
  end

  def waiver_agreements_accepted
    return if @reservation.nil?
    @reservation.assigned_waiver_agreement_templates.each do |wat|
      wat_id = wat.id
      self.send(:add_error, I18n.t('errors.messages.accepted'), "waiver_agreement_template_#{wat_id}") unless @waiver_agreement_templates.include?("#{wat_id}")
    end
  end
end
