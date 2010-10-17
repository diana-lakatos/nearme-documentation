class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.integer :user_id
      t.integer :workplace_id
      t.string :activity
      t.timestamps
    end
    add_index :feeds, :workplace_id
  end

  def self.down
    drop_table :feeds
  end
end
