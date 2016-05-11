class ChangeReservationsCountToOrdersCount < ActiveRecord::Migration
  def change
    add_column :users, :orders_count, :integer, default: 0
    add_column :user_instance_profiles, :orders_count, :integer, default: 0
  end
end
