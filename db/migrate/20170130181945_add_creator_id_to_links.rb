class AddCreatorIdToLinks < ActiveRecord::Migration
  def change
    add_column :links, :creator_id, :integer
    add_index :links, :creator_id
  end
end
