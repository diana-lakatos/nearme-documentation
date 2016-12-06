class AddMarkForDestructionForDataSourceContents < ActiveRecord::Migration
  def change
    add_column :data_source_contents, :mark_for_deletion, :boolean, default: false
  end
end
