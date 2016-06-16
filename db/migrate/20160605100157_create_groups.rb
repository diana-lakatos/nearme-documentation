class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer  :instance_id
      t.integer  :creator_id
      t.hstore   :properties, default: ''
      t.datetime :deleted_at
      t.integer  :transactable_type_id

      t.string   :cover_image
      t.text     :image_transformation_data

      t.string   :name
      t.text     :summary
      t.text     :description

      t.boolean  :featured, default: false

      t.datetime :draft_at, default: nil
      t.timestamps
    end

    add_index :groups, [:instance_id, :creator_id]
  end
end
