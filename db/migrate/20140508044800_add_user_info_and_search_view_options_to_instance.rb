class AddUserInfoAndSearchViewOptionsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :user_info_in_onboarding_flow, :boolean, :default => false
    add_column :instances, :default_search_view, :string
  end
end
