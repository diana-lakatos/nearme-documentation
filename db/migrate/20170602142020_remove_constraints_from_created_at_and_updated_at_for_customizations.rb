class RemoveConstraintsFromCreatedAtAndUpdatedAtForCustomizations < ActiveRecord::Migration
  def up
    change_column :customizations, :created_at, :datetime, null: true
    change_column :customizations, :updated_at, :datetime, null: true
  end

  def down
    change_column :customizations, :created_at, :datetime, null: false
    change_column :customizations, :updated_at, :datetime, null: false
  end
end
