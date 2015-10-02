class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.integer  :instance_id
      t.integer  :category_id
      t.string   :name
      t.text     :description
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :topics, [:instance_id, :category_id]

    create_table :project_topics do |t|
      t.integer  :instance_id
      t.integer  :project_id
      t.integer :topic_id
      t.timestamps
    end
    add_index :project_topics, [:instance_id, :project_id, :topic_id]

    create_table :user_topics do |t|
      t.integer  :instance_id
      t.integer  :user_id
      t.integer :topic_id
      t.timestamps
    end
    add_index :user_topics, [:instance_id, :user_id, :topic_id]
  end
end

