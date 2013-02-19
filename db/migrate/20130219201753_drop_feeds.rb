class DropFeeds < ActiveRecord::Migration
  def self.up
    drop_table :feeds
  end

  def self.down
    create_table :feeds do |t|
      t.integer :user_id
      t.integer :workplace_id
      t.string :activity
      t.timestamps
    end
    add_index :feeds, :workplace_id
  end
end
