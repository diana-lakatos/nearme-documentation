class AddOnlyFirstNameAsUserSlugToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :only_first_name_as_user_slug, :boolean, default: false, null: false
  end
end
