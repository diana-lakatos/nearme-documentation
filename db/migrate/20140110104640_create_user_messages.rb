class CreateUserMessages < ActiveRecord::Migration
  def change
    create_table :user_messages do |t|
      t.integer :thread_owner_id
      t.integer :author_id, null: false
      t.integer :thread_recipient_id
      t.integer :thread_context_id
      t.string :thread_context_type
      t.text :body
      t.boolean :read
      t.boolean :archived_for_owner, default: false
      t.boolean :archived_for_recipient, default: false

      t.timestamps
    end
  end
end
