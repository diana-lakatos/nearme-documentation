class AddDraftAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :draft_at, :datetime, default: nil
  end
end
