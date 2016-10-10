class MerchantAccountService
  delegate :form_path, :form_data, to: :@concrete_service

  def initialize(merchantable)
    @merchantable = merchantable
    @concrete_service = case payment_gateway.try(:name)
               when 'Braintree Marketplace'
                 MerchantAccountService::BraintreeMarketplace
               when 'Paypal'
                 MerchantAccountService::Paypal
               end.try(:new, @merchantable)
  end

  def needs_merchant_account?
    payment_gateway.try(:supports_company_onboarding?) && !merchant_account.persisted?
  end

  def payment_gateway
    @payment_gateway ||= PlatformContext.current.instance.payout_gateways(@merchantable.iso_country_code).first
  end

  def merchant_account
    @merchant_account ||= @merchantable.merchant_accounts.where(payment_gateway: payment_gateway).first_or_initialize
  end

  def update(data)
    @merchant_account.assign_attributes(form_data(data))
  end
end
