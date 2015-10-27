# This line of code below makes sure Spree::Stock::Estimator is already loaded
if Spree::Stock::Estimator.methods.include?(:new)
  module ShippoExtensions
    class ShippoApiMethodCallingError < StandardError
    end

    class SpreeExtensions

      def self.purchase_shippo_quoted_shipping_rate(shippo_rate_id)
        shippo_api = self.get_shippo_api_instance

        shippo_api.purchase_rate(shippo_rate_id)
      end

      def self.create_shippo_spree_objects_for_package(package)
        return if package.try(:order).try('completed?')
        products = package.contents.map(&:variant).map(&:product).compact.uniq
        company = products.try(:first).try(:company)
        return if company.nil?
        shippo_address_to = ShippoApi::ShippoAddressInfo.new(ShippoApi::ShippoToAddressFillerFromSpree.new(package.order.ship_address, package))
        shippo_address_from = ShippoApi::ShippoAddressInfo.new(ShippoApi::ShippoFromAddressFillerFromSpree.new(company))

        shippo_parcel = ShippoApi::ShippoParcelInfo.new(ShippoApi::ShippoParcelInfoFillerFromSpree.new(package))

        shippo_customs_item = nil
        shippo_customs_declaration = nil

        destination_country = package.order.ship_address.try(:country).try(:iso)
        origin_country = package.stock_location.try(:country).try(:iso)
        if (destination_country != origin_country) && origin_country != nil
          items_quantity = package.contents.inject(0) { |sum, li| sum += li.quantity }
          items_value = package.contents.inject(0) { |sum, li| sum += li.quantity*li.price }

          shippo_customs_item = ShippoApi::ShippoCustomsItemInfo.new(
            :description => package.contents.first.try(:description),
            :quantity => items_quantity,
            :net_weight => package.weight,
            :mass_unit => :oz,
            :value_amount => items_value,
            :value_currency => 'USD',
            :origin_country => origin_country,
          )

          shippo_customs_declaration = ShippoApi::ShippoCustomsDeclarationInfo.new(
            :contents_explanation => package.contents.first.try(:description),
            :certify => true,
            :certify_signer => package.stock_location.name,
            :items => shippo_customs_item["object_id"]
          )
        end

        insurance = nil
        if products.first.insurance_amount > 0 && package.try(:order).try('insurance_enabled?')
          insurance = {
            insurance_amount: products.first.insurance_amount.to_f,
            insurance_currency: products.first.currency,
            extra: {
              insurance_content: products.first.name
            }
          }
        end

        shippo_api = self.get_shippo_api_instance
        rates = shippo_api.get_rates(shippo_address_from, shippo_address_to, shippo_parcel, shippo_customs_item, shippo_customs_declaration, insurance)

        if !package.try(:order).try(:id).nil?
          Spree::ShippingMethod.where(:order_id => package.order.id).destroy_all
        end

        if rates.length > 0
          package.contents.each do |item|
            if item.variant.shipping_category.blank?
              shipping_category = Spree::ShippingCategory.create(
                :name => "Shippo Auto-created #{self.get_random_string_for_id}",
                :instance_id => item.variant.instance_id,
                :company_id => item.variant.company_id,
                :partner_id => item.variant.partner_id,
                :user_id => item.variant.user_id
              )

              item.variant.product.update_attribute(:shipping_category_id, shipping_category.id)
            end
          end

          shipping_categories = package.contents.map { |item| item.variant.shipping_category }.compact.uniq
          #shipping_categories.each do |shipping_category|
          #  shipping_category.shipping_methods.destroy_all
          #end

          if shipping_categories.length > 0
            shipping_category = shipping_categories.first

            rates.each do |rate|
              shipping_method = Spree::ShippingMethod.create!(
                :name => "#{rate[:provider]} #{rate[:servicelevel_name]}",
                :display_on => 'both',
                :instance_id => shipping_category.instance_id,
                :company_id => shipping_category.company_id,
                :partner_id => shipping_category.partner_id,
                :user_id => shipping_category.user_id,
                :order_id => package.order.id,
                :precalculated_cost => rate[:amount],
                :calculator => Spree::Calculator::Shipping::PrecalculatedCostCalculator.new,
                :shipping_categories => [shipping_category],
                :shippo_rate_id => rate[:object_id],
                :insurance_amount => rate[:insurance_amount],
                :insurance_currency => rate[:insurance_currency]
              )

            end
          end
        end
      rescue
        # Ignore, the shipping method list will be empty
      end

      def self.get_shippo_api_instance
        return ShippoApi::ShippoApi.new(PlatformContext.current.instance.shippo_api_token)
      end

      def self.get_random_string_for_id
        o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
        (0..10).map { o[rand(o.length)] }.join
      end
    end
  end

  module Spree
    module Stock
      class Estimator
        old_shipping_rates = instance_method(:shipping_rates)
        old_shipping_methods = instance_method(:shipping_methods)

        def get_shippo_order_status(package)
          result = nil

          products = package.contents.map(&:variant).map(&:product).compact.uniq
          shippo_products_present = false
          non_shippo_products_present = false
          products.each do |product|
            if product.shippo_enabled?
              shippo_products_present = true
            else
              non_shippo_products_present = true
            end
          end

          if shippo_products_present && non_shippo_products_present
            result = :mixed
          elsif shippo_products_present
            result = :shippo
          else
            result = :normal
          end

          result
        end

        define_method(:shipping_rates) do |package, shipping_method_filter = ShippingMethod::DISPLAY_ON_FRONT_END|
          shippo_order_status = get_shippo_order_status(package)

          if shippo_order_status == :shippo
            ShippoExtensions::SpreeExtensions.create_shippo_spree_objects_for_package(package)
          end

          if shippo_order_status == :mixed
            []
          else
            old_shipping_rates.bind(self).(package, shipping_method_filter)
          end
        end

        define_method(:shipping_methods) do |package, ui_filter|
          shippo_order_status = get_shippo_order_status(package)

          if shippo_order_status == :shippo
            Spree::ShippingMethod.where(:order_id => package.order.id)
          elsif shippo_order_status == :mixed
            # This is not required though, as the master method shipping_rates
            # will return an empty list in this case
            []
          else
            old_shipping_methods.bind(self).(package, ui_filter)
          end
        end
      end
    end
  end
end

