class MerchantAccountService::BraintreeMarketplace
  def initialize(merchant_account)
    @merchant_account = merchant_account
  end

  def form_path
    'dashboard/company/merchant_accounts/braintree_marketplace'
  end

  def form_data(data)
    data.slice([:bank_routing_number, :bank_account_number, :email, :phone_number])
  end

  def custom_authorize_options
    {
      merchant_account_id: external_id
    }
  end
end
