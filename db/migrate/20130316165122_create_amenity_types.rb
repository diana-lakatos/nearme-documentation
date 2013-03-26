class CreateAmenityTypes < ActiveRecord::Migration

  def change
    create_table :amenity_types do |t|
      t.string :name
      t.integer :position
      t.timestamps
    end
    add_column :amenities, :amenity_type_id, :integer
    add_index :amenities, :amenity_type_id
  end

end
