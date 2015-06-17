class CountryPaymentGateway < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  validate :payment_gateway_id, :country_alpha2_code

  belongs_to :instance
  belongs_to :payment_gateway

  delegate :name, :requires_company_onboarding?, :active_merchant_class, to: :payment_gateway

  def country
    IsoCountryCodes.find(country_alpha2_code)
  end
end
