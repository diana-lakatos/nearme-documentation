class AddApprovedToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :approved, :boolean, default: false, null: false
  end
end
