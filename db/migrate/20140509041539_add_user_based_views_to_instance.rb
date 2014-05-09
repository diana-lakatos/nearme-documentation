class AddUserBasedViewsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :user_based_marketplace_views, :boolean, :default => false
  end
end
