class AddNameAndLocationIndexes < ActiveRecord::Migration
  def self.up
    add_index :workplaces, :latitude
    add_index :workplaces, :longitude
    add_index :workplaces, :name
  end

  def self.down
  end
end
