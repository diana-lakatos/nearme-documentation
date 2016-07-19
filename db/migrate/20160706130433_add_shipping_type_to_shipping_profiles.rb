class AddShippingTypeToShippingProfiles < ActiveRecord::Migration
  def change
    add_column :shipping_profiles, :shipping_type, :string, default: 'predefined'
  end
end
