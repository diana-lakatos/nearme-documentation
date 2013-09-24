class MoveEmailTemplatesFromInstanceToThemes < ActiveRecord::Migration
  def change
    remove_column :email_templates, :instance_id
    add_column :email_templates, :theme_id, :integer
    add_index :email_templates, :theme_id
  end
end
