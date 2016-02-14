class AddRawAddressToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :raw_address, :boolean, default: false, null: false
  end
end
