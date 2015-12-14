class ReservationRequest < Form

  include Payment::PaymentModule

  attr_accessor :dates, :start_minute, :end_minute, :book_it_out, :exclusive_price, :guest_notes,
    :card_number, :card_exp_month, :card_exp_year, :card_code, :card_holder_first_name,
    :card_holder_last_name, :payment_method_nonce, :waiver_agreement_templates, :documents,
    :checkout_extra_fields, :express_checkout_redirect_url, :mobile_number, :delivery_ids,
    :delivery_type
  attr_reader   :reservation, :listing, :location, :user, :client_token, :payment_method_nonce

  delegate :confirm_reservations?, :location, :billing_authorizations, :company, :timezone, to: :@listing
  delegate :country_name, :country_name=, :country, to: :@user
  delegate :guest_notes, :quantity, :quantity=, :action_hourly_booking?, :reservation_type=,
    :credit_card_payment?, :manual_payment?, :remote_payment?, :nonce_payment?, :currency,
    :service_fee_amount_host_cents, :total_amount_cents, :create_billing_authorization,
    :express_token, :express_token=, :express_payer_id, :service_fee_guest_without_charges,
    :additional_charges, :shipping_costs_cents, :service_fee_amount_guest_cents, :merchant_subject, :shipments,
    :shipments_attributes=, :payment_method=, :payment_method, :payment_method_id, :billing_authorization,
    to: :@reservation

  before_validation :build_documents, :if => lambda { reservation.present? && documents.present? }

  validates :listing,      presence: true
  validates :reservation,  presence: true
  validates :user,         presence: true
  validates :delivery_ids, presence: true, if: -> { with_delivery? &&  reservation.shipments.any? }

  validate :validate_acceptance_of_waiver_agreements
  validate :validate_credit_card, if: lambda { reservation.present? && reservation.credit_card_payment? }
  validate :validate_empty_files, if: lambda { reservation.present? }

  def initialize(listing, user, platform_context, attributes = {}, checkout_extra_fields = {})
    @listing = listing
    @waiver_agreement_templates = []
    @checkout_extra_fields = CheckoutExtraFields.new(user, checkout_extra_fields)
    @user = @checkout_extra_fields.user
    if @listing
      @reservation = @listing.reservations.build
      @instance = platform_context.instance
      @reservation.currency = @listing.currency
      @reservation.time_zone = timezone
      @reservation.company = @listing.company
      @reservation.guest_notes = attributes[:guest_notes]
      @reservation.book_it_out_discount = @listing.book_it_out_discount if attributes[:book_it_out] == 'true'
      if attributes[:exclusive_price] == 'true'
        @reservation.exclusive_price_cents = @listing.exclusive_price_cents
        attributes[:quantity] = @listing.quantity # ignore user's input, exclusive is exclusive - full quantity
      end
      @client_token = payment_gateway.try(:client_token)
      @reservation.user = user
      @reservation.additional_charges << get_additional_charges(attributes)
      @reservation = @reservation.decorate
      attributes = update_shipments(attributes)
      store_attributes(attributes)
    end
    build_return_shipment

    if @user
      @user.phone ||= @user.mobile_number
      @card_holder_first_name ||= @user.first_name
      @card_holder_last_name ||= @user.last_name
    end

    if @listing
      if @reservation.action_hourly_booking? || @listing.schedule_booking?
        @start_minute = start_minute.try(:to_i)
        @end_minute = end_minute.try(:to_i)
      else
        @start_minute = nil
        @end_minute   = nil
      end

      if listing.schedule_booking?
        if @dates.is_a?(String)
          @start_minute = @dates.to_datetime.try(:min).to_i + (60 * @dates.to_datetime.try(:hour).to_i)
          @end_minute = @start_minute
          @dates = [@dates.try(:to_datetime).try(:to_date).try(:to_s)]
        end
      else
        @dates = @dates.split(',') if @dates.is_a?(String)
      end
      @dates.try(:reject, &:blank?).each do |date_string|
        @reservation.add_period(Date.parse(date_string), start_minute, end_minute)
      end
    end
  end

  def express_return_url
    PlatformContext.current.decorate.build_url_for_path("/listings/#{self.listing.to_param}/reservations/return_express_checkout")
  end

  def express_cancel_return_url
    PlatformContext.current.decorate.build_url_for_path("/listings/#{self.listing.to_param}/reservations/cancel_express_checkout")
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      first_name: card_holder_first_name.to_s,
      last_name: card_holder_last_name.to_s,
      number: card_number.to_s,
      month: card_exp_month.to_s,
      year: card_exp_year.to_s,
      verification_value: card_code.to_s
    )
  end

  def process
    @checkout_extra_fields.assign_attributes! if @checkout_extra_fields.are_fields_present?
    @checkout_extra_fields.valid?
    @checkout_extra_fields.errors.full_messages.each { |m| add_error(m, :base) }
    clear_errors(:cc)
    if @checkout_extra_fields.valid? && valid? && payment_gateway.authorize(self)
      if !payment_gateway.supports_recurring_payment? || @reservation.credit_card_id = payment_gateway.store_credit_card(user, credit_card)
        return save_reservation
      else
        add_error(I18n.t('reservations_review.errors.internal_payment', :cc))
      end
    end
    false
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

  def is_free?
    @listing.try(:action_free_booking?) && @reservation.try(:additional_charges).try(:count).try(:zero?)
  end

  def with_delivery?
    PlatformContext.current.instance.shippo_enabled? && (@listing.rental_shipping_type == 'delivery' || (@listing.rental_shipping_type == 'both' && delivery_type == 'delivery'))
  end

  # We don't process taxes for reservations
  def tax_total_cents
    0
  end

  def line_items
    [@reservation]
  end

  def total_amount_cents_without_shipping
    total_amount_cents - shipping_costs_cents
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

  def get_additional_charges(attributes)
    additional_charge_ids = AdditionalChargeType.get_mandatory_and_optional_charges(attributes.delete(:additional_charge_ids)).pluck(:id)
    additional_charges = additional_charge_ids.map { |id|
      AdditionalCharge.new(
        additional_charge_type_id: id,
        currency: currency
      )
    }
    additional_charges
  end

  def payment_method_nonce=(token)
    return false if token.blank?
    @payment_method_nonce = token
    @reservation.payment_method = payment_method
  end

  def user_has_mobile_phone_and_country?
    user && user.country_name.present? && user.mobile_number.present?
  end

  def save_reservation
    remove_empty_optional_documents
    User.transaction do
      checkout_extra_fields.save! if checkout_extra_fields.are_fields_present?
      set_cancellation_policy
      reservation.save!
    end
  rescue ActiveRecord::RecordInvalid => error
    add_errors(error.record.errors.full_messages)
    false
  end

  def set_cancellation_policy
    transactable_type = reservation.listing.transactable_type
    if transactable_type.cancellation_policy_enabled.present?
      reservation.cancellation_policy_hours_for_cancellation = transactable_type.cancellation_policy_hours_for_cancellation
      if payment_gateway.supports_partial_refunds?
        reservation.cancellation_policy_penalty_percentage = transactable_type.cancellation_policy_penalty_percentage
      end
    end
  end

  def build_documents
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
    attachable = Attachable::AttachableService.new(Attachable::PaymentDocument, document_params)
    if attachable.valid? && document = attachable.get_attachable
      reservation.payment_documents << document
    else
      reservation.payment_documents.build(document_params)
    end
  end

  def build_document document_params
    if reservation.listing.document_requirements.blank? &&
        PlatformContext.current.instance.documents_upload_enabled? &&
        !PlatformContext.current.instance.documents_upload.is_vendor_decides?

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

  def remove_empty_optional_documents
    if reservation.payment_documents.present?
      reservation.payment_documents.each do |document|
        if document.file.blank? && document.payment_document_info.document_requirement.item.upload_obligation.optional?
          reservation.payment_documents.delete(document)
        end
      end
    end
  end

  def active_merchant_payment?
    reservation.credit_card_payment? || reservation.nonce_payment?
  end

  def validate_acceptance_of_waiver_agreements
    return if @reservation.nil?
    @reservation.assigned_waiver_agreement_templates.each do |wat|
      wat_id = wat.id
      self.send(:add_error, I18n.t('errors.messages.accepted'), "waiver_agreement_template_#{wat_id}") unless @waiver_agreement_templates.include?("#{wat_id}")
    end
  end

  def validate_credit_card
    errors.add(:cc, I18n.t('buy_sell_market.checkout.invalid_cc')) unless credit_card.valid?
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

end
