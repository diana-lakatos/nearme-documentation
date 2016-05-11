class Currency < ActiveRecord::Base
  default_scope { order(:iso_code) }

  has_many :orders, primary_key: :iso_code


  has_many :payment_gateways_currencies
  has_many :payout_gateways_currencies,  -> { where(payout: true) }, class_name: 'PaymentGatewaysCurrency'

  has_many :payment_gateways, through: :payment_gateways_currencies
  has_many :payout_gateways, through: :payout_gateways_currencies, class_name: "PaymentGateway"

  def to_s
    iso_code
  end

  def full_name
    "#{name} (#{iso_code})"
  end
end
