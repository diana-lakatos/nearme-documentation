class AddOnboardingRequiredToInstanceProfileTypes < ActiveRecord::Migration
  class InstanceProfileType < ActiveRecord::Base
  end

  def change
    add_column :user_profiles, :enabled, :boolean, default: false
    UserProfile.update_all(enabled: true)
  end
end
