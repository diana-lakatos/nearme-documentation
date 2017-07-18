# frozen_string_literal: true
class Country < ActiveRecord::Base
  validates :iso, uniqueness: true

  default_scope { order(:name) }

  has_many :payment_gateways_countries
  has_many :payout_gateways_countries, -> { where(payout: true) }, class_name: 'PaymentGatewaysCountry'

  has_many :payment_gateways, through: :payment_gateways_countries
  has_many :payout_gateways, through: :payout_gateways_countries, class_name: 'PaymentGateway'

  has_many :states

  def self.educated_guess_find(country)
    return country if country.is_a?(Country)
    country = country&.strip
    Country.where('iso = ? OR iso3 = ? OR name = ?', country&.upcase, country&.upcase, country).first
  end

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
