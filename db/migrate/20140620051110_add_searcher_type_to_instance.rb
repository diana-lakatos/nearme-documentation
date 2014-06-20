class AddSearcherTypeToInstance < ActiveRecord::Migration
  def up
    add_column :instances, :searcher_type, :string
  end

  def down
    remove_column :instances, :searcher_type
  end
end
