class MerchantAccount::BraintreeMarketplaceMerchantAccount < MerchantAccount

  def update_data(data)
    self.data = data.slice("bank_routing_number", "bank_account_number", "ssn", "date_of_birth", "tos").symbolize_keys if data
    true
  end

  def form_path
    'dashboard/company/merchant_accounts/braintree_marketplace'
  end

  def data_correctness
    unless skip_validation
      errors.add(:data, 'Bank routing number is blank') if data[:bank_routing_number].blank?
      errors.add(:data, 'Bank account number is blank') if data[:bank_account_number].blank?
      errors.add(:data, 'Terms of Services must be accepted') if data[:tos] != "1"
    end
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
      data[:bank_account_number] = data[:bank_account_number].to_s[-4, 4]
      data[:bank_routing_number] = nil
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
        ssn: data[:ssn],
        date_of_birth: data[:date_of_birth],
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
        account_number: data[:bank_account_number],
        routing_number: data[:bank_routing_number]
      },
    }
  end

  def create_params
    common_params.deep_merge({
      tos_accepted: data[:tos] == "1",
      id: custom_braintree_id,
      master_merchant_account_id: payment_gateway.settings[:master_merchant_account_id]
    })
  end

  def custom_braintree_id
    "#{merchantable.class.name.underscore}_#{merchantable.id}"
  end
end

