class RenameTestSettingsInsShippingProviders < ActiveRecord::Migration
  def change
    rename_column :shippings_shipping_providers, :encrypted_test_settings, :encrypted_settings
    remove_column :shippings_shipping_providers, :encrypted_live_settings, :string
  end
end
