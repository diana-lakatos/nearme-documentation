class CreateTransactableTopics < ActiveRecord::Migration
  def change
    create_table :transactable_topics do |t|
      t.integer  :instance_id
      t.integer  :transactable_id
      t.integer :topic_id
      t.timestamps null: false
    end
  end
end
