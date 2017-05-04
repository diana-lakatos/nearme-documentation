class CreateMarketplaceBuilderSettings < ActiveRecord::Migration
  def change
    create_table :marketplace_builder_settings do |t|
      t.integer :status
      t.json :manifest
      t.integer :marketplace_release_id

      t.integer :instance_id
      t.timestamps
    end

    add_index :marketplace_builder_settings, :instance_id, unique: true

    add_column :instances, :marketplace_builder_settings_id, :integer

    Instance.all.each do |instance|
      MarketplaceBuilderSettings.create! status: 'ready', manifest: {}, instance_id: instance.id
    end
  end
end
