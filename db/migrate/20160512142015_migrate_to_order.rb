class MigrateToOrder < ActiveRecord::Migration
  def change
    add_column :instances, :use_cart, :boolean, default: false
    add_column :reservation_periods, :line_item_id, :integer, index: true
  end
end
