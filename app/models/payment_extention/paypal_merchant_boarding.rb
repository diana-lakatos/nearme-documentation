module PaymentExtention::PaypalMerchantBoarding

  def boarding_url(merchant)
    @merchant = merchant
    boarding_url_host_and_path + boarding_url_params
  end

  private

  def available_products
    products = "addipmt"                                   # Express Checkout
    # products = "wp_pro"  if @merchant.iso_country_code == 'US' # Payments Pro
  end

  def boarding_url_host_and_path
    prefix = test_mode? ? 'sandbox' : 'www'
    "https://#{prefix}.paypal.com/webapps/merchantboarding/webflow/externalpartnerflow?"
  end

  def boarding_url_params
    {
      "partnerId" => settings["partner_id"],
      "productIntentID" => available_products,
      "countryCode" => @merchant.iso_country_code,
      "displayMode" => "regular", # or minibrowser
      "integrationType" => "T",
      "permissionNeeded" => merchant_permissions,
      "returnToPartnerUrl" => host + '/dashboard/company/payouts/boarding_complete',#CGI::escape(host + '/dashboard/company/payouts/boarding_complete'),
      "receiveCredentials" => "FALSE",
      "showPermissions" => "TRUE",
      "productSelectionNeeded" => "FALSE",
      "merchantID" => @merchant.merchant_token
    }.map { |k,v| "#{k}=#{v}" }.join('&')
  end

  def merchant_permissions
    [
      "EXPRESS_CHECKOUT",
      "REFUND",
      "AUTH_CAPTURE",
      "REFERENCE_TRANSACTION",
      "BILLING_AGREEMENT",
      # "DIRECT_PAYMENT",
      # "BUTTON_MANAGER",
      # "ACCOUNT_BALANCE",
      # "TRANSACTION_DETAILS",
      # "TRANSACTION_SEARCH",
      # "RECURRING_PAYMENTS",
      # "MANAGE_PENDING_TRANSACTION_STATUS",
      # "NON_REFERENCED_CREDIT",
      # "MASS_PAY",
      # "ENCRYPTED_WEBSITE_PAYMENTS",
      # "MOBILE_CHECKOUT",
      # "AIR_TRAVEL",
      # "INVOICING",
      # "ACCESS_BASIC_PERSONAL_DATA",
    ].join(',')
  end

  def boarding_supported_countries
    ['US', 'GB', 'IT', 'ES', 'DE', 'FR', 'AT', 'BE', 'DK', 'NL', 'NO', 'PL', 'SE', 'CH', 'TR']
  end

end