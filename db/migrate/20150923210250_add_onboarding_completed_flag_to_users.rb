class AddOnboardingCompletedFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :onboarding_completed, :boolean, default: false
  end
end
