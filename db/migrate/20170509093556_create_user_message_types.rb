class CreateUserMessageTypes < ActiveRecord::Migration
  def change
    create_table :user_message_types do |t|
      t.integer :instance_id
      t.string :type
      t.timestamps null: false
      t.index [:instance_id, :type], name: 'user_message_types_main_idx'
    end

    add_column :user_messages, :user_message_type_id, :integer
    add_column :user_messages, :properties, :hstore
    add_index :user_messages, :user_message_type_id
  end
end
