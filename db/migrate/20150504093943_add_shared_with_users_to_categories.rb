class AddSharedWithUsersToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :shared_with_users, :boolean
  end
end
