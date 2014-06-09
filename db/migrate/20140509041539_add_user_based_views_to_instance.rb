class AddUserBasedViewsToInstance < ActiveRecord::Migration

  def up
    add_column :instances, :user_based_marketplace_views, :boolean, :default => false
  end

  def down
    remove_column :instances, :user_based_marketplace_views
  end
end
