class CreateDesks < ActiveRecord::Migration
  def self.up
    create_table :desks do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :desks
  end
end
