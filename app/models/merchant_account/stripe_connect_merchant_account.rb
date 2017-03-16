# frozen_string_literal: true
require 'stripe'

class MerchantAccount::StripeConnectMerchantAccount < MerchantAccount
  ATTRIBUTES = %w(account_type currency bank_routing_number bank_account_number tos ssn_last_4).freeze
  ACCOUNT_TYPES = %w(individual company).freeze

  SUPPORTED_CURRENCIES = {
    'NZ'   => %w(NZD),
    'US'   => %w(USD),
    'CA'   => %w(USD CAD),
    'AU'   => %w(AUD),
    'JP'   => %w(JPY),
    'EUUK' => %w(EUR GBP USD)
  }.freeze

  include MerchantAccount::Concerns::DataAttributes

  has_many :owners, -> { order(:id) }, class_name: 'MerchantAccountOwner::StripeConnectMerchantAccountOwner',
                                       foreign_key: 'merchant_account_id', dependent: :destroy

  validates :bank_account_number, presence: true
  validates :bank_routing_number, presence: true, if: :based_in_us
  validates :account_type, inclusion: { in: ACCOUNT_TYPES }
  validates :tos, acceptance: true

  accepts_nested_attributes_for :owners, allow_destroy: true

  delegate :direct_charge?, :country_spec, to: :payment_gateway
  delegate :business_tax_id, :business_vat_id, :personal_id_number, :first_name, :last_name,
           :dob_date, :current_address, to: :account_owner

  def account_owner
    owners.first || owners.build
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
      self.response = result.to_yaml
      self.bank_account_number = mask_number(bank_account_number)

      upload_documents(result)
      set_data_attributes(result)
      change_state_if_needed(result)

      true
    elsif result.error
      errors.add(:base, result.error)
      false
    else
      false
    end
  end

  def set_data_attributes(result)
    data[:fields_needed] = result.verification.fields_needed
    data[:disabled_reason] = localize_error(result.verification.disabled_reason)
    data[:due_by] = result.verification.due_by
    data[:verification_message] = localize_error(result.legal_entity.verification.details_code)
    data[:currency] = result.default_currency
    data[:secret_key] = result.keys.secret if result.keys.is_a?(Stripe::StripeObject)
  end

  def tos_acceptance_timestamp
    Time.now.to_i
  end

  def create_params
    update_params.deep_merge(
      managed: true,
      country: iso_country_code,
      email: merchantable.creator.email,
      tos_acceptance: {
        ip: merchantable.creator.current_sign_in_ip,
        date: tos_acceptance_timestamp
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
    legal_entity_hash = {
      type: account_type,
      business_name: merchantable.name,
      address: address_hash,
      personal_address: address_hash,
      dob: {
        day:   dob_date.day,
        month: dob_date.month,
        year:  dob_date.year
      },
      ssn_last_4:         ssn_last_4,
      business_tax_id:    business_tax_id,
      business_vat_id:    business_vat_id,
      personal_id_number: personal_id_number,
      first_name: first_name,
      last_name: last_name
    }

    if owners.size == 1
      legal_entity_hash[:additional_owners] = ''
    else
      legal_entity_hash[:additional_owners] = []
      owners.to_a[1..-1].each do |owner|
        dob = owner.dob_date
        legal_entity_hash[:additional_owners] << {
          first_name: owner.first_name,
          last_name:  owner.last_name,
          address: {
            country:     iso_country_code,
            state:       owner.current_address.state_code || owner.current_address.state,
            city:        owner.current_address.city,
            postal_code: owner.current_address.postcode,
            line1:       owner.current_address.address || owner.current_address.street,
            line2:       owner.current_address.address2
          },
          dob: {
            day:   dob.day,
            month: dob.month,
            year:  dob.year
          }
        }
      end
    end

    bank_account_hash.merge(legal_entity: legal_entity_hash).merge(payment_gateway_config)
  end

  def bank_account_hash
    {
      bank_account: {
        country: iso_country_code,
        currency: get_currency,
        account_number: bank_account_number.to_s.delete(' ').scan(/^\w{0,2}[\d\-]*$/).first,
        routing_number: bank_routing_number.to_s.delete(' ').scan(/^[\d\-]*$/).first
      }
    }
  end

  def address_hash
    {
      country: iso_country_code,
      state: current_address.state_code || current_address.state,
      city: current_address.city,
      postal_code: current_address.postcode,
      line1: current_address.address || current_address.street,
      line2: current_address.address2
    }
  end

  def address
    merchantable.company_address.try(:dup) || merchantable.creator.try(:current_address).try(:dup) || Address.new
  end

  def change_state_if_needed(stripe_account, &_block)
    if !verified? && stripe_account.charges_enabled && stripe_account.transfers_enabled
      verify(persisted?)
      yield('verified') if block_given?
    elsif verified? && !(stripe_account.charges_enabled && stripe_account.transfers_enabled)
      # 'failed' state is only possible when account was verfied previously
      # in case it's pending we just wait for verification first.
      failure(persisted?)
      yield('failed') if block_given?
    elsif account_incomplete?
      yield('incomplete') if block_given?
    end
  end

  def account_incomplete?
    return true if data[:fields_needed].present?
    return true if data[:disabled_reason].present?
    return true if data[:verification_message].present?
    return true if data[:due_by].present?
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
    when 'NZ'
      'NZD'
    else
      currency
    end
  end

  def location
    iso_country_code.in?(%w(US CA AU JP NZ)) ? iso_country_code.downcase : 'euuk'
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
      month = ((Time.current.day > monthly_anchor) ? Time.current.month + 1 : Time.current.month).modulo(12)
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
      if payment_gateway.transfer_schedule &&
         %w(daily weekly monthly).include?(payment_gateway.transfer_schedule[:interval])
        data[:payment_gateway_config][:transfer_schedule] = payment_gateway.transfer_schedule
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

  def mask_number(number)
    number.sub(/.*(?=\d{4}$)/) { |x| '*' * x.size }
  end

  def localize_error(error_code)
    return if error_code.blank?
    I18n.t('activerecord.errors.models.merchant_account.error_codes.' + error_code.tr('.', '_'))
  end

  def based_in_us
    iso_country_code == 'US'
  end
end
