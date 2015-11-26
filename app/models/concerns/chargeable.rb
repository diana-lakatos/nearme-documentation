# This module standardize all "chargable" objects
#

# Quick explanation:
#   * subtotal_amount_cents:
#     - for Spree::Order it sumary of all line items, shipping and tax
#     - for Reservation it service times quantity
#   * tax_amount_cents:
#     - for Spree::Order is counted automaticaly
#     - for Reservation TODO
#   * shipping_amount_cents:
#     - for Spree::Order is counted automaticaly
#     - for Reservation - sum of all shippmehts
#   * service_fee_amount_host_cents/service_fee_amount_guest_cents:
#     - for Spree::Order is based on Instance service_fee_guest_percent/service_fee_host_percent
#     - for Reservation - defined individually per ServiceType
#   * service_additional_charges_cents
#     - the same for Spree::Order and Reservation defined by MPO in admin panel
#   * host_additional_charges_cents
#     - not yet implemented - it's a framework to AdditionalCharges future improvements when host define his own
#       AdditionalChargeType that is then calculated in payout for Host.
#   * total_service_amount_cents
#     - used in imediate payment - total service costs summarized

module Chargeable
  extend ActiveSupport::Concern

  included do
    monetize :subtotal_amount_cents, with_model_currency: :currency
    monetize :service_fee_amount_guest_cents, with_model_currency: :currency
    monetize :service_fee_amount_host_cents, with_model_currency: :currency
    monetize :total_service_fee_amount_cents, with_model_currency: :currency
    monetize :service_additional_charges_cents, with_model_currency: :currency
    monetize :host_additional_charges_cents, with_model_currency: :currency
    monetize :total_additional_charges_cents, with_model_currency: :currency
    monetize :total_amount_cents, with_model_currency: :currency
    monetize :shipping_amount_cents, with_model_currency: :currency
    monetize :tax_amount_cents, with_model_currency: :currency
    monetize :total_service_amount_cents, with_model_currency: :currency
  end

  def service_fee_amount_guest_cents
    fees_persisted? ? super : (subtotal_amount_cents * service_fee_guest_percent / BigDecimal(100))
  end

  def service_fee_amount_host_cents
    fees_persisted? ? super : (subtotal_amount_cents * service_fee_host_percent / BigDecimal(100))
  end

  def total_service_fee_amount_cents
    service_fee_amount_host_cents + service_fee_amount_guest_cents
  end

  def service_additional_charges_cents
    if self.persisted?
      additional_charges.service.map(&:amount_cents).sum
    else
      additional_charges.select{|a| a.commission_receiver == 'mpo'}.map(&:amount_cents).sum
    end
  end

  def host_additional_charges_cents
    if self.persisted?
      additional_charges.host.map(&:amount_cents).sum
    else
      additional_charges.select{|a| a.commission_receiver == 'host'}.map(&:amount_cents).sum
    end
  end

  def total_additional_charges_cents
    service_additional_charges_cents + host_additional_charges_cents
  end

  def monetize(amount)
    Money.new(amount*Money::Currency.new(self.currency).subunit_to_unit, currency)
  end

  def total_amount_cents
    subtotal_amount_cents + tax_amount_cents + shipping_amount_cents + service_fee_amount_guest_cents + total_additional_charges_cents
  end

  def total_service_amount_cents
    service_fee_amount_host_cents + service_fee_amount_guest_cents + service_additional_charges_cents
  end

end
