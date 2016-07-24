class RefactorTagIndexes < ActiveRecord::Migration
  def self.up
    remove_index :tags, :name

    add_index :tags, [:name, :instance_id], unique: true, name: 'tags_idx'
  end

  def self.down
    add_index :tags, :name, unique: true

    remove_index :tags, [:name, :instance_id]
  end  
end
