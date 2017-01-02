class AddAvailabilityTemplateIdToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :availability_template_id, :integer
    add_column :instance_profile_types, :default_availability_template_id, :integer
  end
end
