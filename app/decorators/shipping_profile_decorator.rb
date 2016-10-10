class ShippingProfileDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include CurrencyHelper

  delegate_all

  def shipping_rules_collection
    shipping_rules.map do |sr|
      displayed_name = []
      displayed_name << sr.name
      displayed_name << I18n.t('order.shipments.processing_time', days: sr.processing_time) if sr.processing_time.to_i > 0
      displayed_name << (sr.use_shippo_for_price? ? I18n.t('order.shipments.address_based_price') : render_money(sr.price))
      [
        displayed_name.join(' - '),
        sr.id,
        { data: { use_shippo: sr.use_shippo_for_price, is_pickup: sr.is_pickup } }
      ]
    end
  end
end
