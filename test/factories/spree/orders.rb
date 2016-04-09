FactoryGirl.define do
  factory :order, class: Spree::Order do
    user
    company
    bill_address
    completed_at nil
    email { user.email }

    factory :order_with_totals do
      after(:create) do |order|
        create(:line_item, order: order)
        order.line_items.reload # to ensure order.line_items is accessible after
      end
    end

    factory :order_with_line_items do
      bill_address
      ship_address

      ignore do
        line_items_count 5
      end

      after(:create) do |order, evaluator|
        create_list(:line_item, evaluator.line_items_count, order: order, currency: order.currency)
        order.line_items.reload
        order.products.update_all(company_id: order.company_id)

        # For some reason shipment is created with the new StockLocation which has no stock items
        create(:shipment, shipping_methods: [FactoryGirl.create(:shipping_method)], stock_location: order.products.first.stock_items.first.stock_location, order: order, address: FactoryGirl.create(:address_engine))

        order.shipments.reload

        order.update!
      end

      factory :order_waiting_for_delivery do
        state 'delivery'
      end

      factory :order_waiting_for_payment do
        state 'payment'
      end

      factory :completed_order_with_totals do
        state 'complete'

        after(:create) do |order|
          order.refresh_shipment_rates
          order.update_column(:completed_at, Time.now)
        end

        factory :completed_order_with_pending_payment do
          after(:create) do |order|
            create(:payment, amount: order.total, order: order)
          end
        end

        factory :order_ready_to_ship do
          payment_state 'paid'
          shipment_state 'ready'
          after(:create) do |order|
            create(:payment,
              subtotal_amount: order.subtotal_amount + order.tax_amount + order.shipping_amount,
              service_fee_amount_guest: order.service_fee_amount_guest,
              service_fee_amount_host: order.service_fee_amount_host,
              payable: order
            )
            order.shipments.each do |shipment|
              shipment.inventory_units.each { |u| u.update_column('state', 'on_hand') }
              shipment.update_column('state', 'ready')
            end
            order.reload
          end

          factory :shipped_order do
            after(:create) do |order|
              order.shipments.each do |shipment|
                shipment.inventory_units.each { |u| u.update_column('state', 'shipped') }
                shipment.update_column('state', 'shipped')
              end
              order.reload
            end

          end
        end

        factory :reviewable_order do
          archived_at { Time.zone.now }
        end
      end
    end
  end
end
