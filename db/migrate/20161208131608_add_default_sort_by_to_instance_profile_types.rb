class AddDefaultSortByToInstanceProfileTypes < ActiveRecord::Migration
  def change
    add_column :instance_profile_types, :default_sort_by, :string
  end
end
