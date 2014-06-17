class CreateAmazonMoveLog < ActiveRecord::Migration
  def change
    create_table :amazon_move_logs do |t|
      t.integer :entity_id
      t.string :entity_type
      t.timestamps
    end
    add_index :amazon_move_logs, [:entity_id, :entity_type]
  end
end
