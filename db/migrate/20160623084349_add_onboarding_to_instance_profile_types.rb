class AddOnboardingToInstanceProfileTypes < ActiveRecord::Migration
  def up
    add_column :instance_profile_types, :onboarding, :boolean, default: false
  end

  def down
  end
end
