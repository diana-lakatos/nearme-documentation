class CreateMarketplaceReleases < ActiveRecord::Migration
  def change
    create_table :marketplace_releases do |t|
      t.string :name
      t.string :creator
      t.string :zip_file
      t.integer :status
      t.text :error

      t.integer :instance_id
      t.timestamp :deleted_at
      t.timestamps
    end

    add_index :marketplace_releases, :instance_id
  end
end
