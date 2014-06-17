class CreateConfidentialFiles < ActiveRecord::Migration
  def change
    create_table :confidential_files do |t|
      t.string :caption
      t.integer :instance_id
      t.integer :uploader_id
      t.integer :owner_id
      t.string :owner_type
      t.string :file
      t.text :comment
      t.string :state
      t.datetime :deleted_at

      t.index :instance_id
      t.index :uploader_id
      t.index [:owner_id, :owner_type]
      t.timestamps
    end
    add_column :instances, :onboarding_verification_required, :boolean, default: false
  end
end
