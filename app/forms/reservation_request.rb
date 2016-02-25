class ReservationRequest < Form

  attr_accessor :dates, :start_minute, :end_minute, :book_it_out, :exclusive_price, :guest_notes,
    :waiver_agreement_templates, :documents, :checkout_extra_fields, :mobile_number, :delivery_ids,
    :delivery_type, :total_amount_check
  attr_reader   :reservation, :listing, :location, :user, :client_token, :payment

  delegate :confirm_reservations?, :location, :company, :timezone, to: :@listing
  delegate :country_name, :country_name=, :country, to: :@user
  delegate :guest_notes, :quantity, :action_hourly_booking?, :reservation_type=, :currency,
    :service_fee_amount_guest, :additional_charges, :shipments, :shipments_attributes=, to: :@reservation

  validates :listing,      presence: true
  validates :reservation,  presence: true
  validates :user,         presence: true
  validates :delivery_ids, presence: true, if: -> { with_delivery? &&  reservation.shipments.any? }

  validate :validate_acceptance_of_waiver_agreements
  validate :validate_reservation
  validate :validate_empty_files, if: lambda { reservation.present? }
  validate :validate_total_amount
  validate :validate_payment

  def initialize(listing, user, attributes = {}, checkout_extra_fields = {})
    @listing = listing
    @waiver_agreement_templates = []
    @checkout_extra_fields = CheckoutExtraFields.new(user, checkout_extra_fields)
    @user = @checkout_extra_fields.user

    if @listing
      @reservation = @listing.reservations.build
      @reservation.currency = @listing.currency
      @reservation.time_zone = timezone
      @reservation.company = @listing.company
      @reservation.guest_notes = attributes[:guest_notes]
      @reservation.book_it_out_discount = @listing.book_it_out_discount if attributes[:book_it_out] == 'true'
      if attributes[:exclusive_price] == 'true'
        @reservation.exclusive_price_cents = @listing.exclusive_price_cents
        attributes[:quantity] = @listing.quantity # ignore user's input, exclusive is exclusive - full quantity
      end

      @reservation.user = user
      @reservation = @reservation.decorate
      attributes = update_shipments(attributes)

      build_return_shipment

      if @user
        @user.phone ||= @user.mobile_number
      end

      if attributes.try(:[], 'reservation').present?
        reservation_attributes = attributes.delete('reservation')
        attributes.merge!(reservation_attributes)
      end
      store_attributes(attributes)
      @reservation.calculate_prices

      @reservation.build_additional_charges(attributes)
      @payment = @reservation.build_payment(attributes.try(:[], :payment_attributes) || {}).decorate
    end
  end

  def additional_charge_ids=(additional_charge_ids)
  end

  def dates=dates
    @dates = dates
    if @listing
      if @reservation.action_hourly_booking? || @listing.schedule_booking?
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
        date = Date.parse(date_string) rescue Date.strptime(date_string, "%m/%d/%Y")
        @reservation.add_period(date, start_minute, end_minute)
      end
    end
  end

  def quantity=(qty)
    reservation.quantity = qty.presence || 1
  end

  def process
    @checkout_extra_fields.assign_attributes! if @checkout_extra_fields.are_fields_present?
    @checkout_extra_fields.valid?
    @checkout_extra_fields.errors.full_messages.each { |m| add_error(m, :base) }
    !!(@checkout_extra_fields.valid? && valid? && @payment.authorize && save_reservation)
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

  private

  def transactable_type
    @transactable_type ||= reservation.listing.transactable_type
  end

  def user_has_mobile_phone_and_country?
    user && user.country_name.present? && user.mobile_number.present?
  end

  def save_reservation
    remove_empty_optional_documents
    User.transaction do
      checkout_extra_fields.save! if checkout_extra_fields.are_fields_present?
      set_cancellation_policy
      @reservation.save!
    end
  rescue ActiveRecord::RecordInvalid => error
    add_errors(error.record.errors.full_messages)
    false
  end

  def set_cancellation_policy
    if transactable_type.cancellation_policy_enabled.present?
      reservation.cancellation_policy_hours_for_cancellation = transactable_type.cancellation_policy_hours_for_cancellation
      if payment.payment_gateway.supports_partial_refunds?
        reservation.cancellation_policy_penalty_percentage = transactable_type.cancellation_policy_penalty_percentage
      end
    end
  end

  def documents_attributes=(documents)
    documents.each do |document|
      document_requirement_id = document.try(:fetch, 'payment_document_info_attributes', nil).try(:fetch, 'document_requirement_id', nil)
      document_requirement = DocumentRequirement.find_by(id: document_requirement_id)
      upload_obligation = document_requirement.try(:item).try(:upload_obligation)
      if upload_obligation && !upload_obligation.not_required?
        build_or_attach_document document
      else
        build_document(document)
      end
      documents.delete(document)
    end
  end

  def build_or_attach_document(document_params)
    attachable = AttachableService.new(Attachable::PaymentDocument, document_params)
    if attachable.valid? && document = attachable.get_attachable
      reservation.payment_documents << document
    else
      reservation.payment_documents.build(document_params)
    end
  end

  def build_document document_params
    if reservation.listing.document_requirements.blank? &&
        current_instance.documents_upload_enabled? &&
        !current_instance.documents_upload.is_vendor_decides?

      document_params.delete :payment_document_info_attributes
      document_params[:user_id] = @user.id
      document = reservation.payment_documents.build(document_params)
      document_requirement = reservation.listing.document_requirements.build({
        label: I18n.t("upload_documents.file.default.label"),
        description: I18n.t("upload_documents.file.default.description"),
        item: reservation.listing
      })

      reservation.listing.build_upload_obligation(level: UploadObligation.default_level)

      document.build_payment_document_info(
        document_requirement: document_requirement,
        payment_document: document
      )

      reservation.listing.upload_obligation.save
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

  def remove_empty_optional_documents
    if reservation.payment_documents.present?
      reservation.payment_documents.each do |document|
        if document.file.blank? && document.payment_document_info.document_requirement.item.upload_obligation.optional?
          reservation.payment_documents.delete(document)
        end
      end
    end
  end

  def validate_acceptance_of_waiver_agreements
    return if @reservation.nil?
    @reservation.assigned_waiver_agreement_templates.each do |wat|
      wat_id = wat.id
      self.send(:add_error, I18n.t('errors.messages.accepted'), "waiver_agreement_template_#{wat_id}") unless @waiver_agreement_templates.include?("#{wat_id}")
    end
  end

  def validate_reservation
    errors.add(:base, reservation.errors.full_messages.join("\n")) if reservation && !reservation.valid?
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
