class AddInstanceIdToSpreeReturnAuthorizations < ActiveRecord::Migration
  def change
    add_column :spree_return_authorizations, :instance_id, :integer
  end
end
