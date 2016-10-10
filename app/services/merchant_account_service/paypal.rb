class MerchantAccountService::Paypal
  def initialize(merchant_account)
    @merchant_account = merchant_account
  end

  def form_path
    'dashboard/company/merchant_accounts/paypal'
  end

  def form_data(data)
    data.slice([:email])
  end
end
