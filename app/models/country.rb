class Country < ActiveRecord::Base

  validates :iso, uniqueness: true

  default_scope { order(:name) }

  has_many :payment_gateways_countries
  has_many :payout_gateways_countries,  -> { where(payout: true) }, class_name: 'PaymentGatewaysCountry'

  has_many :payment_gateways, through: :payment_gateways_countries
  has_many :payout_gateways, through: :payout_gateways_countries, class_name: "PaymentGateway"

  def alpha2
    iso
  end

  def to_s
    name
  end

  def full_name
    "#{name} (#{iso})"
  end

end

