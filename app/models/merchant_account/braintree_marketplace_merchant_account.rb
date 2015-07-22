class MerchantAccount::BraintreeMarketplaceMerchantAccount < MerchantAccount

  ATTRIBUTES = %w(bank_routing_number bank_account_number ssn date_of_birth tos)
  include MerchantAccount::Concerns::DataAttributes

  with_options unless: :skip_validation do
    validates_presence_of   :bank_routing_number, message: 'Bank routing number is blank'
    validates_presence_of   :bank_account_number, message: 'Bank account number is blank'
    validates_acceptance_of :tos, message: 'Terms of Services must be accepted'
  end

  def onboard!
    result = payment_gateway.onboard!(create_params)
    handle_result(result)
  end

  def update_onboard!
    result = payment_gateway.update_onboard!(custom_braintree_id, common_params)
    handle_result(result)
  end

  def handle_result(result)
    if result.success?
      self.response = result.to_yaml
      bank_account_number = bank_account_number.to_s[-4, 4]
      true
    else
      result.errors.each { |e| errors.add(:data, e.message); }
      false
    end

  end

  def common_params
    {
      individual: {
        first_name: merchantable.first_name,
        last_name: merchantable.last_name,
        email: merchantable.email,
        ssn: ssn,
        date_of_birth: date_of_birth,
        address: {
          street_address: merchantable.address,
          locality: merchantable.city,
          region: (merchantable.address_components.values.find { |arr| arr["types"].include?('administrative_area_level_1') }["short_name"] rescue ""),
          postal_code: merchantable.postcode
        }
      },
      funding: {
        descriptor: merchantable.name,
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: bank_account_number,
        routing_number: bank_routing_number
      },
    }
  end

  def create_params
    common_params.deep_merge({
      tos_accepted: tos == "1",
      id: custom_braintree_id,
      master_merchant_account_id: payment_gateway.settings[:master_merchant_account_id]
    })
  end

  def custom_braintree_id
    "#{merchantable.class.name.underscore}_#{merchantable.id}"
  end
end

