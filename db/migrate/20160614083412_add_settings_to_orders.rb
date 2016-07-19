class AddSettingsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :settings, :hstore, default: ''
  end
end
