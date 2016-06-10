class AddOnlyInstanceAdminsToCustomThemes < ActiveRecord::Migration
  def change
    add_column :custom_themes, :in_use_for_instance_admins, :boolean
  end
end
