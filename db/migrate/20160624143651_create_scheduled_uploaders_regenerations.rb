class CreateScheduledUploadersRegenerations < ActiveRecord::Migration
  def change
    create_table :scheduled_uploaders_regenerations do |t|
      t.integer :instance_id, index: true
      t.string :photo_uploader

      t.timestamps null: false
    end

    add_index :scheduled_uploaders_regenerations, [:instance_id, :photo_uploader], unique: true, name: 'uniq_sur_instance_photo_uploader'
  end
end
