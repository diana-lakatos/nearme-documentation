class AddPreciseSearchToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :precise_search, :boolean, default: false, null: false
  end
end

