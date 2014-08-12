class CreateUserBans < ActiveRecord::Migration
  def change
    create_table :user_bans do |t|
      t.integer :user_id
      t.integer :instance_id
      t.integer :creator_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
