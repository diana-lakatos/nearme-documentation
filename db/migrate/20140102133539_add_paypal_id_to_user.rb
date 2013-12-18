class AddPaypalIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :paypal_id, :string
  end
end
