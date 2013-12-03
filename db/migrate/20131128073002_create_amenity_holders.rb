class CreateAmenityHolders < ActiveRecord::Migration
  def change
    create_table :amenity_holders do |t|
      t.references :amenity
      t.integer :holder_id
      t.string :holder_type

      t.timestamps
    end
    add_index :amenity_holders, :amenity_id
    add_index :amenity_holders, [:holder_id, :holder_type]
  end
end
