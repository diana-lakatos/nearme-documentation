class MerchantAccount::PaypalMerchantAccount < MerchantAccount

  def form_path
    'dashboard/company/merchant_accounts/paypal'
  end

  def update_data(data)
    self.data = data.slice("email").symbolize_keys
  end

end

