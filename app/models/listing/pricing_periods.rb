class Listing < ActiveRecord::Base
  module PricingPeriods
    def add_pricing_period(period, minutes)
      period_getter_name = "#{period.to_s}_period".to_sym
      price_getter_name = "#{period.to_s}_price".to_sym
      price_setter_name = "#{period.to_s}_price=".to_sym


      define_method period_getter_name do
        unit_price = unit_prices.detect { |l| l.period == minutes }
        unit_price ||= unit_prices.build(period: minutes, listing: self)
        unit_price
      end

      define_method price_getter_name do
        send(period_getter_name).price
      end

      define_method price_setter_name do |price|
        period = send(period_getter_name)
        period.price = price
        period.save if period.persisted?
      end
    end
  end
end
