module PaymentExtention::PaypalMerchantBoarding
  WP_PRO = 'wp_pro'
  ADDIPMT = 'addipmt'

  def boarding_url(merchant)
    @merchant = merchant
    boarding_url_host_and_path + boarding_url_params
  end

  private

  def available_products
    if @merchant.iso_country_code == 'US' && !self.supports_express_checkout_payment?
      products = WP_PRO
    else
      products = ADDIPMT
    end
  end

  def boarding_url_host_and_path
    prefix = test_mode? ? 'sandbox' : 'www'
    "https://#{prefix}.paypal.com/webapps/merchantboarding/webflow/externalpartnerflow?"
  end

  def boarding_url_params
    boarding_params = {
      'partnerId' => settings['partner_id'],
      'productIntentID' => available_products,
      'displayMode' => 'regular',
      'integrationType' => 'T',
      'permissionNeeded' => merchant_permissions,
      'returnToPartnerUrl' => host + "/dashboard/company/merchant_accounts/#{@merchant.id}/boarding_complete",
      'receiveCredentials' => 'FALSE',
      'showPermissions' => 'TRUE',
      'productSelectionNeeded' => 'FALSE',
      'merchantID' => @merchant.merchant_token
    }

    # Work around for MPO PayPal based in Australia. Can be removed when PP deal with it on their side.
    if PlatformContext.current.instance.default_country != 'Australia'
      boarding_params.merge!('countryCode' => @merchant.iso_country_code)
    end

    boarding_params.map { |k, v| "#{k}=#{v}" }.join('&')
  end

  def merchant_permissions
    %w(EXPRESS_CHECKOUT REFUND AUTH_CAPTURE REFERENCE_TRANSACTION BILLING_AGREEMENT DIRECT_PAYMENT).join(',')
  end

  def boarding_supported_countries
    %w(US GB IT ES DE FR AT BE DK NL NO PL SE CH TR)
  end
end
