class CreateGroupTransactables < ActiveRecord::Migration
  def change
    create_table :group_transactables do |t|
      t.integer  :instance_id
      t.integer  :group_id
      t.integer  :transactable_id
      t.timestamps null: false
    end
  end
end
