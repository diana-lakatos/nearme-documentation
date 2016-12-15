# frozen_string_literal: true
module ShippoLegacy
  module Order
    extend ActiveSupport::Concern

    included do
      # before_validation :build_return_shipment

      has_many :shipments, dependent: :destroy, inverse_of: :order
      accepts_nested_attributes_for :shipments
      before_validation :copy_billing_address, :remove_empty_documents
    end

    def with_delivery?
      Shippings.enabled? self
    end

    def delivery_ids=(ids)
      errors.add(:delivery_ids, :blank) if shipments.any? && ids.blank?
      if ids.present? && shipments.any?
        ids.split(',').each do |delivery|
          shipments.each do |shipment|
            shipment.shippo_rate_id = delivery.split(':')[1] if shipment.direction == delivery.split(':')[0]
          end
        end
      end
    end

    def delivery_ids
      shipments.map(&:delivery_id).join(',')
    end

    def build_return_shipment
      if shipments.one? && shipments.first.shipping_rule.shipping_profile.shippo_return? && shipping_address.valid?
        outbound_shipping = shipments.first
        inbound_shipping = outbound_shipping.dup
        inbound_shipping.direction = 'inbound'
        shipping_address.create_shippo_address
        shipments << inbound_shipping
      end
    end

    def get_shipping_rates
      return [] if shipments.none?(&:use_shippo?)
      return @options unless @options.nil?
      rates = []
      begin
        # Get rates for both ways shipping (rental shipping)
        shipments.each do |shipment|
          shipment.get_rates(self).map { |rate| rate[:direction] = shipment.direction; rates << rate }
        end
        rates = rates.flatten.group_by { |rate| rate[:servicelevel_name] }
        @options = rates.to_a.map do |_type, rate|
          # Skip if service is available only in one direction
          # next if rate.one?
          price_sum = Money.new(rate.sum { |r| r[:amount_cents].to_f }, rate[0][:currency])
          # Format options for simple_form radio
          [
            [price_sum.format, "#{rate[0][:provider]} #{rate[0][:servicelevel_name]}", rate[0][:duration_terms]].join(' - '),
            rate.map { |r| "#{r[:direction]}:#{r[:object_id]}" }.join(','),
            { data: { price_formatted: price_sum.format, price: price_sum.to_f } }
          ]
        end.compact
      rescue Shippo::APIError
        []
      end
    end

    # def create_shipments!
    #   CreateShippoShipmentsJob.perform(id) if shipments.any?(&:use_shippo?)
    # end

    # TODO: implement with shipping
    def shipped?
      true
    end

    # def shipping_address
    #   if use_billing && billing_address
    #     billing_address.dup
    #   else
    #     super
    #   end
    # end

    def copy_billing_address
      self.shipping_address = nil if use_billing
    end
  end
end
