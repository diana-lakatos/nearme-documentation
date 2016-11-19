# frozen_string_literal: true
class AddAddressToOrderAddress < ActiveRecord::Migration
  def change
    add_column :order_addresses, :address, :string
    add_column :order_addresses, :local_geocoding, :string
    add_column :order_addresses, :latitude, :string
    add_column :order_addresses, :longitude, :string
    add_column :order_addresses, :formatted_address, :string
  end
end
