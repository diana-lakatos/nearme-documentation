class ReservationRequest < Form

  attr_accessor :dates, :start_minute, :end_minute
  attr_accessor :card_number, :card_expires, :card_code, :card_holder_first_name, :card_holder_last_name, :payment_method_nonce
  attr_accessor :waiver_agreement_templates, :documents
  attr_reader   :reservation, :listing, :location, :user, :client_token, :payment_method_nonce

  def_delegators :@reservation, :quantity, :quantity=, :action_hourly_booking?, :reservation_type=
  def_delegators :@reservation, :credit_card_payment?, :manual_payment?, :remote_payment?, :nonce_payment?
  def_delegators :@listing,     :confirm_reservations?, :location
  def_delegators :@user,        :mobile_number, :mobile_number=, :country_name, :country_name=, :country

  before_validation :setup_active_merchant_customer, :if => lambda { reservation and user and user.valid?}
  before_validation :build_documents, :if => lambda { reservation.present? and documents.present? }

  validates :listing,     :presence => true
  validates :reservation, :presence => true
  validates :user,        :presence => true

  validate :validate_phone_and_country
  validate :waiver_agreements_accepted

  validate :files_cannot_be_empty, :if => lambda { reservation.present? }

  def initialize(listing, user, platform_context, attributes = {})
    @listing = listing
    @waiver_agreement_templates = []
    @user = user
    if @listing
      @reservation = listing.reservations.build
      @instance = platform_context.instance
      @reservation.currency = @listing.currency
      @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, @reservation.currency, @listing.company.iso_country_code) if @user
      @client_token = @billing_gateway.try(:client_token) if @billing_gateway.try(:possible?)
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
      if @reservation.action_hourly_booking? || @listing.schedule_booking?
        @start_minute = start_minute.try(:to_i)
        @end_minute = end_minute.try(:to_i)
      else
        @start_minute = nil
        @end_minute   = nil
      end

      if listing.schedule_booking?
        if @dates.is_a?(String)
          @start_minute = @dates.to_datetime.min.to_i + (60 * @dates.to_datetime.hour.to_i)
          @end_minute = @start_minute
          @dates = [@dates.to_datetime.to_date.to_s]
        end
      else
        @dates = @dates.split(',') if @dates.is_a?(String)
      end
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
    @payment_method = if @reservation.listing.action_free_booking?
                        Reservation::PAYMENT_METHODS[:free]
                      elsif @billing_gateway.try(:possible?) && @billing_gateway.try(:remote?)
                        Reservation::PAYMENT_METHODS[:remote]
                      elsif nonce_payment_available? && payment_method_nonce.present?
                        Reservation::PAYMENT_METHODS[:nonce]
                      elsif @billing_gateway.try(:possible?)
                        Reservation::PAYMENT_METHODS[:credit_card]
                      else
                        Reservation::PAYMENT_METHODS[:manual]
                      end
  end

  def nonce_payment_available?
    @billing_gateway.try(:nonce_payment?) if @billing_gateway.try(:possible?)
  end

  private

  def payment_method_nonce=(token)
    return false if token.blank?
    @payment_method_nonce = token
    @reservation.payment_method = payment_method
  end

  def validate_phone_and_country
    add_error("Please complete the contact details", :contact_info) unless user_has_mobile_phone_and_country?
  end

  def user_has_mobile_phone_and_country?
    user && user.country_name.present? && user.mobile_number.present?
  end

  def save_reservation
    remove_empty_optional_documents
    User.transaction do
      user.save!
      if active_merchant_payment?
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

  def setup_active_merchant_customer
    clear_errors(:cc)
    return true unless active_merchant_payment?

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

      if payment_method_nonce.present? || credit_card.valid?
        options = payment_method_nonce.present? ? {payment_method_nonce: payment_method_nonce} : {}
        response = @billing_gateway.authorize(@reservation.total_amount_cents, credit_card, options)
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

  def build_documents
    documents.each do |document|
      document_requirement_id = document.try(:fetch, 'payment_document_info_attributes').try(:fetch, 'document_requirement_id')
      document_requirement = DocumentRequirement.find_by(id: document_requirement_id)
      upload_obligation = document_requirement.try(:item).try(:upload_obligation)
      if upload_obligation && !upload_obligation.not_required?
        build_or_attach_document document
      else
        build_document(document)
      end
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
    PlatformContext.current.instance.documents_upload.is_mandatory?

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

  def remove_empty_optional_documents
    if reservation.payment_documents.present?
      reservation.payment_documents.each do |document|
        if document.file.blank? && document.payment_document_info.document_requirement.item.upload_obligation.optional?
          reservation.payment_documents.delete(document)
        end
      end
    end
  end

  def files_cannot_be_empty
    reservation.payment_documents.each do |document|
      unless document.valid?
        self.errors.add(:base, "file_cannot_be_empty".to_sym) unless self.errors[:base].include?(I18n.t("activemodel.errors.models.reservation_request.attributes.base.file_cannot_be_empty"))
      end
    end
  end

  def active_merchant_payment?
    reservation.credit_card_payment? || reservation.nonce_payment?
  end

  def waiver_agreements_accepted
    return if @reservation.nil?
    @reservation.assigned_waiver_agreement_templates.each do |wat|
      wat_id = wat.id
      self.send(:add_error, I18n.t('errors.messages.accepted'), "waiver_agreement_template_#{wat_id}") unless @waiver_agreement_templates.include?("#{wat_id}")
    end
  end
end
