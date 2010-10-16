class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.references :workplace, :null => false
      t.string :description,   :null => false
      t.string :file,          :null => false

      t.timestamps
    end

    add_index :photos, :workplace_id
  end

  def self.down
    drop_table :photos
  end
end
