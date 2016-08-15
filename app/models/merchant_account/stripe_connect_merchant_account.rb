class MerchantAccount::StripeConnectMerchantAccount < MerchantAccount

  ATTRIBUTES = %w(account_type first_name last_name currency bank_routing_number bank_account_number tos  business_tax_id business_vat_id ssn_last_4 personal_id_number )
  ACCOUNT_TYPES = %w(individual company)

  SUPPORTED_CURRENCIES = {
    'US'   => %w(USD),
    'CA'   => %w(USD CAD),
    'AU'   => %w(AUD),
    'JP'   => %w(JPY),
    'EUUK' => %w(EUR GBP USD),
  }

  include MerchantAccount::Concerns::DataAttributes

  has_many :owners, -> { order(:id) }, class_name: 'MerchantAccountOwner::StripeConnectMerchantAccountOwner', foreign_key: 'merchant_account_id', dependent: :destroy

  has_one :current_address, class_name: 'Address', as: :entity

  validates_presence_of   :bank_routing_number, :bank_account_number, :last_name, :first_name
  validates_presence_of   :personal_id_number, if: Proc.new {|m| m.iso_country_code == 'US'}
  validates_presence_of   :business_tax_id, if: Proc.new {|m| m.iso_country_code == 'US' && m.account_type == 'company'}
  validates_inclusion_of  :account_type, in: ACCOUNT_TYPES
  validates_acceptance_of :tos
  validates_associated :owners
  validate  :validate_current_address
  validate  :validate_owners_documents

  accepts_nested_attributes_for :owners, allow_destroy: true
  accepts_nested_attributes_for :current_address

  def onboard!
    result = payment_gateway.onboard!(create_params)
    handle_result(result)
  end

  def update_onboard!
    result = payment_gateway.update_onboard!(internal_payment_gateway_account_id, update_params)
    handle_result(result)
  end

  def handle_result(result)
    if result.id
      self.internal_payment_gateway_account_id = result.id
      self.data[:fields_needed] = result.verification.fields_needed
      upload_documents(result)
      self.response = result.to_yaml
      self.bank_account_number = result.bank_accounts.first.last4
      self.data[:currency] = result.default_currency
      if result.keys.is_a?(Stripe::StripeObject)
        self.data[:secret_key] = result.keys.secret
      end
      change_state_if_needed(result)
      true
    elsif result.error
      errors.add(:base, result.error)
      false
    else
      false
    end
  end

  def create_params
    update_params.deep_merge(
      managed: true,
      country: iso_country_code,
      email: merchantable.creator.email,
      tos_acceptance: {
        ip: merchantable.creator.current_sign_in_ip,
        date: Time.now.to_i
      },
      legal_entity: {
        address: address_hash,
        first_name: first_name,
        last_name: last_name
      },
      decline_charge_on: {
        cvc_failure: true
      }
    )
  end

  def update_params
    owner = owners.first

    dob = owner.dob_date

    legal_entity_hash = {
      type: account_type,
      business_name: merchantable.name,
      address: address_hash,
      personal_address: address_hash,
      dob: {
        day:   dob.day,
        month: dob.month,
        year:  dob.year
      },
      ssn_last_4:         ssn_last_4,
      business_tax_id:    business_tax_id,
      business_vat_id:    business_vat_id,
      personal_id_number: personal_id_number,
      first_name: first_name,
      last_name: last_name
    }

    if owners.count == 1
      legal_entity_hash.merge!(additional_owners: nil)
    else
      legal_entity_hash.merge!(additional_owners: [])
      owners[1..-1].each do |owner|

        dob = owner.dob_date
        legal_entity_hash[:additional_owners] << {
          first_name: owner.first_name,
          last_name:  owner.last_name,
          address: {
            country:     owner.address_country,
            state:       owner.address_state,
            city:        owner.address_city,
            postal_code: owner.address_postal_code,
            line1:       owner.address_line1,
            line2:       owner.address_line2,
          },
          dob: {
            day:   dob.day,
            month: dob.month,
            year:  dob.year
          }
        }
      end
    end

    payment_gateway_config = { }
    if payment_gateway.config["transfer_schedule"] &&
      ['daily', 'weekly', 'monthly'].include?(payment_gateway.config["transfer_schedule"]["interval"])
      payment_gateway_config["transfer_schedule"] = payment_gateway.config[:transfer_schedule]
    end

    {
      bank_account: {
        country: iso_country_code,
        currency: get_currency,
        account_number: bank_account_number,
        routing_number: bank_routing_number
      }
    }.merge(legal_entity: legal_entity_hash).merge(payment_gateway_config)
  end

  def address_hash
    {
      country: iso_country_code,
      state: address.state,
      city: address.city,
      postal_code: address.postcode,
      line1: address.address,
      line2: address.address2
    }
  end

  def address
    @address = current_address || merchantable.company_address.try(:dup) || merchantable.creator.try(:current_address).try(:dup) || Address.new
    @address.parse_address_components!
    @address
  end

  def change_state_if_needed(stripe_account, &block)
    if !verified? && stripe_account.charges_enabled && stripe_account.transfers_enabled
      if stripe_account.verification.fields_needed.empty?
        verify(persisted?)
        yield('verified') if block_given?
      else
        failure(persisted?)
        yield('failed') if block_given?
      end
    elsif verified? && (!stripe_account.charges_enabled || !stripe_account.transfers_enabled || !stripe_account.verification.fields_needed.empty?)
      failure(persisted?)
      yield('failed') if block_given?
    end
  end

  def get_currency
    case iso_country_code
    when 'US'
      'USD'
    when 'AU'
      'AUD'
    when 'JP'
      'JPY'
    else
      currency
    end
  end

  def has_valid_address?
    address = merchantable.company_address || merchantable.creator.try(:current_address) || Address.new
    address.errors.clear
    address.check_address.blank?
  end

  def location
    iso_country_code.in?(%w(US CA AU JP)) ? iso_country_code.downcase : 'euuk'
  end

  def needs?(attribute)
    fields_needed.try(:include?, attribute)
  end

  def fields_needed
    self.data[:fields_needed] || []
  end

  def iso_country_code
    @iso_country_code ||= address.iso_country_code
  end

  private

  def upload_documents(stripe_account)
    files_data = owners.map { |owner| owner.upload_document(stripe_account.id) }
    if files_data.compact.present?
      stripe_account.legal_entity.verification.document = files_data[0].id
      if stripe_account.legal_entity.additional_owners
        files_data[1..-1].each_with_index do |file_data, index|
          if stripe_account.legal_entity.additional_owners[index]
            stripe_account.legal_entity.additional_owners[index].verification.document = file_data.id
          end
        end
      end
      stripe_account.save
    end
  end


  def validate_current_address
    return if current_address.blank?

    current_address.parse_address_components!
    current_address.errors.clear

    if current_address.check_address && current_address.errors.any?
      errors.add(:current_address, :inacurate)
    end
  end

  def validate_owners_documents
    if iso_country_code == 'US'
      owners.each do |o|
        if (o.attributes['document'] || o.document.file.try(:path)).blank?
          o.errors.add(:document, :blank)
          errors.add(:base, I18n.t('dashboard.merchant_account.document') + " " + I18n.t('errors.messages.blank'))
        end
      end
    end
  end

end
