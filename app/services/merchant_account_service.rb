class MerchantAccountService
  extend Forwardable

  def_delegators :@concrete_service, :form_path, :form_data

  def initialize(merchantable)
    @merchantable = merchantable
    @concrete_service = case payment_gateway.try(:name)
               when 'Braintree Marketplace'
                 MerchantAccountService::BraintreeMarketplace
               when 'Paypal'
                 MerchantAccountService::Paypal
               end.try(:new, @merchantable)
  end

  def country_payment_gateway
    @country_payment_gateway ||= PlatformContext.current.instance.country_payment_gateways.where(country_alpha2_code: @merchantable.iso_country_code).first
  end

  def needs_merchant_account?
    country_payment_gateway.try(:requires_company_onboarding?) && !merchant_account.persisted?
  end

  def payment_gateway
    @payment_gateway ||= country_payment_gateway.try(:payment_gateway)
  end

  def merchant_account
    @merchant_account ||= @merchantable.merchant_accounts.where(payment_gateway: payment_gateway).first_or_initialize
  end

  def update(data)
    @merchant_account.assign_attributes(form_data(data))
  end

end

