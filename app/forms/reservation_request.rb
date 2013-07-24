class ReservationRequest < Form

  attr_accessor :dates, :start_minute, :end_minute
  attr_accessor :card_number, :card_expires, :card_code
  attr_reader   :reservation, :listing, :location, :user

  def_delegators :@reservation, :payment_method, :payment_method=, :quantity, :quantity=
  def_delegators :@reservation, :credit_card_payment?, :manual_payment?
  def_delegators :@listing,     :confirm_reservations?, :hourly_reservations?, :location
  def_delegators :@user,        :phone, :phone=, :mobile_number, :mobile_number=, :country_name, :country_name=, :country

  before_validation :setup_credit_card_customer

  validates :listing,     :presence => true
  validates :reservation, :presence => true
  validates :user,        :presence => true

  validate :validate_phone_and_country

  def initialize(listing, user, attributes = {})
    @listing          = listing
    @user             = user

    @user.phone_required = true if @user

    if @listing
      @reservation      = listing.reservations.build
      @reservation.user = user
    end

    store_attributes(attributes)
    add_periods
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

  private

    def validate_phone_and_country
      add_error("Please complete the contact details", :contact_info) unless user.try(:has_phone_and_country?)
    end

    def save_reservation
      User.transaction do
        user.save!
        reservation.save!
      end
    rescue ActiveRecord::RecordInvalid => error
      add_errors(error.record.errors.full_messages)
      false
    end

    def add_periods
      if listing
        if listing.hourly_reservations?
          @start_minute = start_minute.try(:to_i)
          @end_minute = end_minute.try(:to_i)
        else
          @start_minute = nil
          @end_minute   = nil
        end

        (dates || []).each do |date_str|
          reservation.add_period(Date.parse(date_str), start_minute, end_minute)
        end
      end
    end

    def setup_credit_card_customer
      clear_errors(:cc)
      return true unless using_credit_card?

      begin
        self.card_expires = card_expires.to_s.strip
        card_details = User::BillingGateway::CardDetails.new(
          number:       card_number.to_s,
          expiry_month: card_expires.to_s[0,2],
          expiry_year:  card_expires.to_s[-2,2],
          cvc:          card_code.to_s
        )

        if card_details.valid?
          user.billing_gateway.store_card(card_details)
        else
          add_error("Those credit card details don't look valid", :cc)
        end
      rescue User::BillingGateway::BillingError => e
        add_error(e.message, :cc)
      end
    end

    def using_credit_card?
      reservation.credit_card_payment?
    end

end