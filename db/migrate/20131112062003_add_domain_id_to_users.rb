class AddDomainIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :domain_id, :integer
    add_index :users, :domain_id
  end
end
