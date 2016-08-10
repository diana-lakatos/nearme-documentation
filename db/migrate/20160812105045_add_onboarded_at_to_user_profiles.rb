class AddOnboardedAtToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :onboarded_at, :datetime
  end
end
