class AddSearchOnlyEnabledProfilesToInstanceProfileTypes < ActiveRecord::Migration
  def change
    add_column :instance_profile_types, :search_only_enabled_profiles, :boolean
  end
end
