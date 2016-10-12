# This is temporary work around for missing newset API implementation
# for braintree SDK in Active Merchant
# Can be removed and adjusted when Active Merchant supports newest API

module BraintreeSDK
  def self.included(klass)
    klass.class_eval do
      remove_method :create_transaction_parameters
    end
  end

  def create_transaction_parameters(money, credit_card_or_vault_id, options)
    parameters = {
      amount: amount(money).to_s,
      payment_method_nonce: options[:payment_method_nonce],
      order_id: options[:order_id],
      customer: {
        id: options[:store] == true ? '' : options[:store],
        email: scrub_email(options[:email])
      },
      options: {
        store_in_vault: options[:store] ? true : false,
        submit_for_settlement: options[:submit_for_settlement]
      }
    }

    parameters[:custom_fields] = options[:custom_fields]
    parameters[:device_data] = options[:device_data] if options[:device_data]
    if merchant_account_id = (options[:merchant_account_id] || @merchant_account_id)
      parameters[:merchant_account_id] = merchant_account_id
    end

    parameters[:recurring] = true if options[:recurring]
    if options[:payment_method_nonce].blank?
      if credit_card_or_vault_id.is_a?(String) || credit_card_or_vault_id.is_a?(Integer)
        if options[:payment_method_token]
          parameters[:payment_method_token] = credit_card_or_vault_id
        else
          parameters[:customer_id] = credit_card_or_vault_id
        end
      else
        parameters[:customer].merge!(
          first_name: credit_card_or_vault_id.first_name,
          last_name: credit_card_or_vault_id.last_name
        )
        parameters[:credit_card] = {
          number: credit_card_or_vault_id.number,
          cvv: credit_card_or_vault_id.verification_value,
          expiration_month: credit_card_or_vault_id.month.to_s.rjust(2, '0'),
          expiration_year: credit_card_or_vault_id.year.to_s
        }
      end
    end
    parameters[:billing] = map_address(options[:billing_address]) if options[:billing_address] && !options[:payment_method_token]
    parameters[:shipping] = map_address(options[:shipping_address]) if options[:shipping_address]
    parameters[:channel] = application_id if application_id.present? && application_id != 'ActiveMerchant'
    parameters
  end
end

ActiveMerchant::Billing::BraintreeBlueGateway.send(:include, BraintreeSDK)
