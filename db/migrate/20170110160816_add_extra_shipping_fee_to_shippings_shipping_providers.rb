class AddExtraShippingFeeToShippingsShippingProviders < ActiveRecord::Migration
  def change
    add_column :shippings_shipping_providers, :mpo_extra_shipping_fee, :integer, default: 0
  end
end
