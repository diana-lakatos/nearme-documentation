class AddPartnerIdAndInstanceIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :partner_id, :integer
    add_column :users, :instance_id, :integer

    add_index :users, :partner_id
    add_index :users, :instance_id
  end
end
