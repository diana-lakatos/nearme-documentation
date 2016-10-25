class AddInstanceIdToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :instance_id, :integer
  end
end
