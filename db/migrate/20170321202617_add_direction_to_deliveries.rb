class AddDirectionToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :direction, :string

    Delivery.reset_column_information

    Instance.where(id: 194).each do |instance|
      instance.set_context!

      Order.find_each do |order|
        inbound, outbound = order.deliveries.order('created_at asc').take(2)

        inbound&.update_column(:direction, Delivery::TYPES[:inbound])
        outbound&.update_column(:direction, Delivery::TYPES[:outbound])
      end
    end
  end
end
