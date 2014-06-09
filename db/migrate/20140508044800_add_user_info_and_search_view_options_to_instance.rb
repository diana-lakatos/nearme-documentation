class AddUserInfoAndSearchViewOptionsToInstance < ActiveRecord::Migration
  def up
    add_column :instances, :user_info_in_onboarding_flow, :boolean, :default => false
    add_column :instances, :default_search_view, :string
  end

  def down
    remove_column :instances, :user_info_in_onboarding_flow
    remove_column :instances, :default_search_view
  end
end

