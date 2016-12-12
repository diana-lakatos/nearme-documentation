# frozen_string_literal: true
require 'stripe'

class MerchantAccount::StripeConnectMerchantAccount < MerchantAccount
  ATTRIBUTES = %w(account_type first_name last_name currency bank_routing_number bank_account_number tos business_tax_id business_vat_id ssn_last_4 personal_id_number).freeze
  ACCOUNT_TYPES = %w(individual company).freeze

  SUPPORTED_CURRENCIES = {
    'US'   => %w(USD),
    'CA'   => %w(USD CAD),
    'AU'   => %w(AUD),
    'JP'   => %w(JPY),
    'EUUK' => %w(EUR GBP USD)
  }.freeze

  include MerchantAccount::Concerns::DataAttributes

  has_many :owners, -> { order(:id) }, class_name: 'MerchantAccountOwner::StripeConnectMerchantAccountOwner',
                                       foreign_key: 'merchant_account_id', dependent: :destroy

  has_one :current_address, class_name: 'Address', as: :entity

  validates :bank_routing_number, :bank_account_number, :last_name, :first_name, presence: true
  validates :personal_id_number, presence: { if: proc { |m| m.iso_country_code == 'US' } }
  validates :business_tax_id, presence: { if: proc { |m| m.iso_country_code == 'US' && m.account_type == 'company' } }
  validates :account_type, inclusion: { in: ACCOUNT_TYPES }
  validates :tos, acceptance: true
  validate :validate_current_address
  validate :validate_owners_documents

  accepts_nested_attributes_for :owners, allow_destroy: true
  accepts_nested_attributes_for :current_address

  delegate :direct_charge?, :country_spec, to: :payment_gateway

  after_initialize :build_current_address_if_needed
  def build_current_address_if_needed
    self.build_current_address unless self.current_address
  end

  def onboard!
    result = payment_gateway.onboard!(create_params)
    handle_result(result)
  end

  def update_onboard!
    result = payment_gateway.update_onboard!(external_id, update_params)
    handle_result(result)
  end

  def handle_result(result)
    if result.id
      self.external_id = result.id
      data[:fields_needed] = result.verification.fields_needed
      upload_documents(result)
      self.response = result.to_yaml
      self.bank_account_number = mask_number(bank_account_number)
      data[:currency] = result.default_currency
      data[:secret_key] = result.keys.secret if result.keys.is_a?(Stripe::StripeObject)
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

    if owners.size == 1
      legal_entity_hash[:additional_owners] = nil
    else
      legal_entity_hash[:additional_owners] = []
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
            line2:       owner.address_line2
          },
          dob: {
            day:   dob.day,
            month: dob.month,
            year:  dob.year
          }
        }
      end
    end

    {
      bank_account: {
        country: iso_country_code,
        currency: get_currency,
        account_number: bank_account_number.to_s.scan(/\d+/).first,
        routing_number: bank_routing_number.to_s.scan(/\d+/).first
      }
    }.merge(legal_entity: legal_entity_hash).merge(payment_gateway_config)
  end

  def address_hash
    {
      country: iso_country_code,
      state: current_address.state_code,
      city: current_address.city,
      postal_code: current_address.postcode,
      line1: current_address.address,
      line2: current_address.address2
    }
  end

  def address
    merchantable.company_address.try(:dup) || merchantable.creator.try(:current_address).try(:dup) || Address.new
  end

  def change_state_if_needed(stripe_account, &_block)
    if (data[:disabled_reason] = localize_error(stripe_account.verification.disabled_reason)).present?
      failure(persisted?)
      return
    end

    if !verified? && stripe_account.charges_enabled && stripe_account.transfers_enabled
      if stripe_account.verification.fields_needed.empty? && stripe_account.legal_entity.verification.status == 'verified'
        verify(persisted?)
        yield('verified') if block_given?
      else
        if stripe_account.legal_entity.verification.details.present?
          data[:verification_details] = stripe_account.legal_entity.verification.details
          data[:verification_message] = localize_error(stripe_account.legal_entity.verification.details_code)
        end
        failure(persisted?)
        yield('failed') if block_given?
      end
    elsif verified? && ((stripe_account.legal_entity.verification.status != 'verified') || !stripe_account.charges_enabled || !stripe_account.transfers_enabled || !stripe_account.verification.fields_needed.empty?)
      failure(persisted?)
      yield('failed') if block_given?
    end
  end

  def custom_options
    if direct_charge?
      { stripe_account: external_id }
    else
      { destination: external_id }
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
    data[:fields_needed] || []
  end

  def iso_country_code
    @iso_country_code ||= current_address.iso_country_code || address.iso_country_code || merchantable.iso_country_code
  end

  def next_transfer_date(transfer_created_on = Date.today)
    case transfer_interval
    when 'daily'
      transfer_created_on + transfer_schedule[:delay_days].to_i
    when 'weekly'
      day_of_the_week = Date::DAYNAMES.index(transfer_schedule[:weekly_anchor].to_s.capitalize)
      Time.current.to_date + (day_of_the_week - Time.current.wday).modulo(7).days
    when 'monthly'
      month = (Time.current.day > monthly_anchor) ? Time.current.month + 1 : Time.current.month
      year = month == 1 && Time.current.month == 12 ? Time.current.year + 1 : Time.current.year
      Date.parse("#{monthly_anchor}/#{month}/#{year}")
    end
  end

  def weekly_or_monthly_transfers?
    %w(daily monthly).include?(transfer_interval)
  end

  def supported_currencies
    SUPPORTED_CURRENCIES[location.upcase]
  end

  def minimum_company_fields
    company_fields[:minimum].map { |k| FIELD_MAP[k] }.select { |k| !k.blank? }
  end

  private

  def individual_fields
    verification_fields[:individual]
  end

  def company_fields
    verification_fields[:company]
  end

  def verification_fields
    @verification_fields ||= country_spec.verification_fields
  end

  def country_spec
    @country_spec ||= payment_gateway.country_spec
  end

  def payment_gateway_config
    if data[:payment_gateway_config].blank?
      data[:payment_gateway_config] = {}
      if payment_gateway.config[:transfer_schedule] &&
         %w(daily weekly monthly).include?(payment_gateway.config[:transfer_schedule][:interval])
        data[:payment_gateway_config][:transfer_schedule] = payment_gateway.config[:transfer_schedule]
      end
    end

    data[:payment_gateway_config]
  end

  def transfer_schedule
    payment_gateway_config[:transfer_schedule] || {}
  end

  def transfer_interval
    transfer_schedule[:interval]
  end

  def monthly_anchor
    transfer_schedule[:monthly_anchor].to_i
  end

  def upload_documents(stripe_account)
    files_data = owners.map { |owner| owner.upload_document(stripe_account.id) }
    if files_data.compact.present?
      stripe_account.legal_entity.verification.document = files_data[0].id
      if stripe_account.legal_entity.respond_to?(:additional_owners) && stripe_account.legal_entity.additional_owners
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

    errors.add(:current_address, :inacurate) if current_address.valid? && current_address.check_address
  end

  def validate_owners_documents
    if iso_country_code == 'US'
      owners.each do |o|
        if (o.attributes['document'] || o.document.file.try(:path)).blank?
          o.errors.add(:document, :blank)
          errors.add(:base, I18n.t('dashboard.merchant_account.document') + ' ' + I18n.t('errors.messages.blank'))
        end
      end
    end
  end

  def mask_number(number)
    number.sub(/.*(?=\d{4}$)/) { |x| '*' * x.size }
  end

  def localize_error(error_code)
    return if error_code.blank?
    I18n.t('activerecord.errors.models.merchant_account.error_codes.' + error_code.gsub('.', '_'))
  end
end
