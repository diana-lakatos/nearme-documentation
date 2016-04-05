class ReservationRequest < Form

  attr_accessor :dates, :start_minute, :end_minute, :book_it_out, :exclusive_price, :guest_notes,
    :waiver_agreement_templates, :documents, :checkout_extra_fields, :mobile_number, :delivery_ids,
    :delivery_type, :total_amount_check, :start_time, :dates_fake
  attr_reader   :reservation, :listing, :location, :user, :client_token, :payment

  delegate :confirm_reservations?, :location, :company, :timezone, to: :@listing
  delegate :country_name, :country_name=, :country, to: :@user
  delegate :id, :guest_notes, :quantity, :action_hourly_booking?, :booking_type=, :currency,
    :service_fee_amount_guest, :additional_charges, :shipments, :shipments_attributes=, :category_ids, :category_ids=,
    :properties, :properties=, :creator_attributes=, :payment_documents, :payment_documents_attributes=, :has_service_fee?,
    :reservation_type, :owner, :owner_attributes=, :address, :build_address, :address_attributes=, to: :@reservation

  validates :listing,      presence: true
  validates :reservation,  presence: true
  validates :user,         presence: true
  validates :delivery_ids, presence: true, if: -> { with_delivery? &&  reservation.shipments.any? }

  validate :validate_acceptance_of_waiver_agreements
  validate :validate_reservation
  validate :validate_empty_files, if: lambda { reservation.present? }
  validate :validate_total_amount
  validate :validate_payment

  def initialize(listing, user, attributes = {}, checkout_extra_fields = {}, last_search_json = {})
    @listing = listing
    @user = user
    @waiver_agreement_templates = []
    # remove with old ui
    @checkout_extra_fields = CheckoutExtraFields.new(@user, checkout_extra_fields)
    @last_search_json = last_search_json

    if @listing
      @reservation = @listing.reservations.build
      @reservation.reservation_type = @listing.service_type.reservation_type
      @reservation.currency = @listing.currency
      @reservation.time_zone = timezone
      @reservation.company = @listing.company
      @reservation.guest_notes = attributes[:guest_notes]
      @reservation.book_it_out_discount = @listing.book_it_out_discount if attributes[:book_it_out] == 'true'
      if attributes[:exclusive_price] == 'true'
        @reservation.exclusive_price_cents = @listing.exclusive_price_cents
        attributes[:quantity] = @listing.quantity # ignore user's input, exclusive is exclusive - full quantity
      end

      @reservation.user = @user
      @reservation = @reservation.decorate
      attributes = update_shipments(attributes)


      if @user
        @user.phone ||= @user.mobile_number
      end

      store_attributes(attributes)
      build_return_shipment
      build_payment_documents
      set_dates

      @reservation.build_additional_charges(attributes)
      @reservation.calculate_prices
      @payment = @reservation.build_payment(attributes.try(:[], :payment_attributes) || {}).decorate
      @deposit = @reservation.build_deposit(attributes.try(:[], :payment_attributes) || {})
    end
  end

  def additional_charge_ids=(additional_charge_ids)
  end

  def set_dates
    set_dates_from_search
    @dates = dates

    if @listing
      if @reservation.action_hourly_booking? || @listing.schedule_booking?
        set_start_minute
        @start_minute = start_minute.try(:to_i)
        @end_minute = end_minute.try(:to_i)
      else
        @start_minute = nil
        @end_minute   = nil
      end

      if @listing.schedule_booking?
        if @dates.is_a?(String)
          timestamp = Time.at(@dates.to_i).in_time_zone(@listing.timezone)
          @start_minute = timestamp.try(:min).to_i + (60 * timestamp.try(:hour).to_i)
          @end_minute = @start_minute
          @dates = [timestamp.try(:to_date).try(:to_s)]
        end
      else
        @dates = @dates.split(',')
      end

      @dates.flatten!
      @dates.reject(&:blank?).each do |date_string|
        begin
          date = Date.parse(date_string)
        rescue
          errors.add(:base, I18n.t('reservations_review.errors.invalid_date'))
          return
        end
        @reservation.add_period(date, start_minute, end_minute)
      end
    end
  end

  def last_search
    @last_search ||= JSON.parse(@last_search_json) rescue {}
  end

  def booking_date_from_search
    last_search['date'].presence || Date.current.to_s
  end

  def booking_time_start_from_search
    last_search['time_from'].presence || 1.hour.from_now.strftime("%k:00").strip
  end

  def set_dates_from_search
    if listing.skip_payment_authorization?
      if dates.blank? && start_time.blank?
        self.dates = booking_date_from_search
        self.start_time = booking_time_start_from_search
      end
      self.dates_fake = I18n.l(Date.parse(dates), format: :day_month_year)
    end
  end

  def set_start_minute
    return unless start_time && start_time.split(':').any?
    hours, minutes = start_time.split(':')
    self.start_minute = hours.to_i * 60 + minutes.to_i
    self.end_minute = start_minute + 90
  end

  def quantity=(qty)
    reservation.quantity = qty.presence || 1
  end

  def form_address(last_search_json)
    return address if address.present?
    if last_search_json
      last_search = JSON.parse(last_search_json, symbolize_names: true) rescue {}
      self.build_address(address: last_search[:loc], longitude: last_search[:lng], latitude: last_search[:lat])
    else
      self.build_address
    end
  end

  def process
    # remove with old ui
    if @checkout_extra_fields.are_fields_present?
      @checkout_extra_fields.assign_attributes!
      reservation.owner = @checkout_extra_fields.user
      @checkout_extra_fields.valid?
      @checkout_extra_fields.errors.full_messages.each { |m| add_error(m, :base) }
    end

    remove_empty_documents
    !!(@checkout_extra_fields.errors.empty? && valid? && authorize_payment && authorize_deposit && save_reservation)
  end

  def authorize_deposit
    !@deposit || @deposit.try(:authorize)
  end

  def authorize_payment
    @listing.skip_payment_authorization? || @payment.try(:authorize)
  end

  def reservation_periods
    reservation.periods
  end

  def update_shipments(attributes)
    if attributes[:delivery_ids].present? && attributes[:shipments_attributes]
      attributes[:delivery_ids].split(',').each do |delivery|
        attributes[:shipments_attributes].each_value do |attribs|
          attribs['shippo_rate_id'] = delivery.split(':')[1] if attribs['direction'] == delivery.split(':')[0]
        end
      end
    end
    attributes
  end

  def with_delivery?
    current_instance.shippo_enabled? && (@listing.rental_shipping_type == 'delivery' || (@listing.rental_shipping_type == 'both' && delivery_type == 'delivery'))
  end

  def get_shipping_rates
    return @options unless @options.nil?
    rates = []
    # Get rates for both ways shipping (rental shipping)
    @reservation.shipments.each do |shipment|
      shipment.get_rates(@reservation).map{|rate| rate[:direction] = shipment.direction; rates << rate }
    end
    rates = rates.flatten.group_by{ |rate| rate[:servicelevel_name] }
    @options = rates.to_a.map do |type, rate|
      # Skip if service is available only in one direction
      next if rate.one?
      price_sum = Money.new(rate.sum{|r| r[:amount_cents].to_f }, rate[0][:currency])
      # Format options for simple_form radio
      [
        [ price_sum.format, "#{rate[0][:provider]} #{rate[0][:servicelevel_name]}", rate[0][:duration_terms]].join(' - '),
        rate.map{|r| "#{r[:direction]}:#{r[:object_id]}" }.join(','),
        { data: { price_formatted: price_sum.format, price: price_sum.to_f } }
      ]
    end.compact
  end

  def to_liquid
    @reservation_request_drop ||= ReservationRequestDrop.new(self)
  end

  private

  def transactable_type
    @transactable_type ||= reservation.listing.transactable_type
  end

  def user_has_mobile_phone_and_country?
    user && user.country_name.present? && user.mobile_number.present?
  end

  def save_reservation
    User.transaction do
      # remove with old ui
      checkout_extra_fields.save! if checkout_extra_fields.are_fields_present?
      set_cancellation_policy
      @payment.save! if @reservation.skip_payment_authorization?
      @reservation.save!
      ReservationMarkAsArchivedJob.perform_later(@reservation.ends_at, @reservation.id) unless @reservation.skip_payment_authorization?
      true
    end
  rescue => error
    add_errors(error.record.errors.full_messages)
    false
  end

  def set_cancellation_policy
    if transactable_type.cancellation_policy_enabled.present?
      reservation.cancellation_policy_hours_for_cancellation = transactable_type.cancellation_policy_hours_for_cancellation
      reservation.cancellation_policy_penalty_hours = transactable_type.cancellation_policy_penalty_hours
      if payment.payment_gateway.supports_partial_refunds?
        reservation.cancellation_policy_penalty_percentage = transactable_type.cancellation_policy_penalty_percentage
      end
    end
  end

  def build_payment_documents
    if payment_documents.empty?
      listing.document_requirements.select(&:should_show_file?).each_with_index do |doc, index|
        payment_documents.new(
          user: @user,
          attachable: reservation,
          payment_document_info_attributes: {
            attachment_id: reservation.id,
            document_requirement_id: doc.id
          }
        )
      end
    end
  end

  def remove_empty_documents
    payment_documents.each do |document|
      payment_documents.delete(document) if document.file.blank? && !document.is_file_required?
    end
  end

  def build_return_shipment
    if with_delivery? && @reservation.shipments.one? && @reservation.shipments.first.shipping_address.valid?
      outbound_shipping = @reservation.shipments.first
      inbound_shipping = outbound_shipping.dup
      inbound_shipping.direction = 'inbound'
      outbound_shipping.shipping_address.create_shippo_address
      inbound_shipping.shipping_address = outbound_shipping.shipping_address
      @reservation.shipments << inbound_shipping
    end
  end

  def payment_attributes=(attributes)
  end

  def validate_acceptance_of_waiver_agreements
    return if @reservation.nil?
    @reservation.assigned_waiver_agreement_templates.each do |wat|
      wat_id = wat.id
      self.send(:add_error, I18n.t('errors.messages.accepted'), "waiver_agreement_template_#{wat_id}") unless @waiver_agreement_templates.include?("#{wat_id}")
    end
  end

  def validate_reservation
    if reservation
      errors.add(:dates, I18n.t('reservations_review.errors.date_in_past')) if reservation.periods.any?{ |p| p.date < Date.current }
      errors.add(:base, reservation.errors.full_messages.join("\n")) if !reservation.valid?
    end
  end

  def validate_empty_files
    reservation.payment_documents.each do |document|
      unless document.valid?
        self.errors.add(:base, "file_cannot_be_empty".to_sym) unless self.errors[:base].include?(I18n.t("activemodel.errors.models.reservation_request.attributes.base.file_cannot_be_empty"))
      end
    end
  end

  def validate_user
    errors.add(:user) if @user.blank? || !@user.valid?
  end

  def validate_payment
    errors.add(:payment) if @payment.blank? || !payment.valid?
  end

  def validate_total_amount
    if @reservation.present? && self.total_amount_check.present? && @reservation.total_amount.cents != self.total_amount_check.to_i
      errors.add(:base, I18n.t("activemodel.errors.models.reservation_request.attributes.base.total_amount_changed"))
    end
  end

  def current_instance
    @current_instance ||= PlatformContext.current.instance
  end

end
