class CreateUserStatusUpdates < ActiveRecord::Migration
  def change
    create_table :user_status_updates do |t|
      t.text :text
      t.integer :user_id
      t.integer :instance_id, index: true

      t.timestamps null: false
    end
  end
end
