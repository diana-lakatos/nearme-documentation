class AddExpandOrdersListToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :expand_orders_list, :boolean, default: true
  end
end
