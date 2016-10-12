class AddGroupIdToMarketplaceErrors < ActiveRecord::Migration
  def change
    add_column :marketplace_errors, :marketplace_error_group_id, :integer, index: true
  end
end
