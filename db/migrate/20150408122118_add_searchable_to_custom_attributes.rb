class AddSearchableToCustomAttributes < ActiveRecord::Migration
  def change
    add_column :custom_attributes, :searchable, :boolean, default: false
  end
end
