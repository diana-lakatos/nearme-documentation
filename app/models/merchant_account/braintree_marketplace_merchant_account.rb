# frozen_string_literal: true
require 'braintree'

class MerchantAccount::BraintreeMarketplaceMerchantAccount < MerchantAccount
  ATTRIBUTES = %w(bank_routing_number bank_account_number ssn date_of_birth terms_of_service first_name last_name email street_address locality region postal_code).freeze
  include MerchantAccount::Concerns::DataAttributes

  with_options unless: :skip_validation do
    validates :bank_routing_number, :bank_account_number, :first_name, :last_name,
              :street_address, :locality, :region, :postal_code, presence: true
    validates :terms_of_service, acceptance: true
  end

  def initialize_defaults
    data.reverse_merge!('terms_of_service' => false,
                        'first_name' => merchantable.try(:first_name),
                        'last_name' => merchantable.try(:last_name),
                        'email' => merchantable.try(:email),
                        'street_address' => merchantable.try(:address),
                        'locality' => merchantable.try(:city),
                        'region' => (begin
                                       merchantable.address_components.values.find { |arr| arr['types'].include?('administrative_area_level_1') }['short_name']
                                     rescue
                                       ''
                                     end),
                        'postal_code' => merchantable.try(:postcode))
  end

  def onboard!
    result = payment_gateway.onboard!(create_params)
    handle_result(result)
  end

  def update_onboard!
    result = payment_gateway.update_onboard!(external_id, common_params)
    handle_result(result)
  end

  def handle_result(result)
    if result.success?
      self.response = result.to_yaml
      data['bank_account_number'] = data['bank_account_number'].to_s[-4, 4]
      self.external_id ||= custom_braintree_id
      true
    else
      result.errors.each { |e| errors.add(:base, e.message); }
      false
    end
  end

  def common_params
    {
      individual: {
        first_name: first_name,
        last_name: last_name,
        email: email,
        ssn: ssn,
        date_of_birth: date_of_birth,
        address: {
          street_address: street_address,
          locality: locality,
          region: region,
          postal_code: postal_code
        }
      },
      funding: {
        descriptor: merchantable.name,
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: bank_account_number,
        routing_number: bank_routing_number
      }
    }
  end

  def create_params
    common_params.deep_merge(tos_accepted: terms_of_service == '1',
                             id: custom_braintree_id,
                             master_merchant_account_id: payment_gateway.settings[:master_merchant_account_id])
  end

  def custom_options
    { merchant_account_id: external_id }
  end

  def custom_braintree_id
    "#{merchantable.class.name.underscore}_#{merchantable.id}"
  end
end
