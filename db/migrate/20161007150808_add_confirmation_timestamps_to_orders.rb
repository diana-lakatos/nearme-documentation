class AddConfirmationTimestampsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :lister_confirmed_at, :datetime
    add_column :orders, :enquirer_confirmed_at, :datetime
  end
end
