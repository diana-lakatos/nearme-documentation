class CountryInstancePaymentGateway < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  validate :instance_payment_gateway_id, :country_alpha2_code

  belongs_to :instance
  belongs_to :instance_payment_gateway

  delegate :name, to: :instance_payment_gateway

  def country
    IsoCountryCodes.find(country_alpha2_code)
  end
end
