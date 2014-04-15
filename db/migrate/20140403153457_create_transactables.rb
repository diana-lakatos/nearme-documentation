class CreateTransactables < ActiveRecord::Migration
  def up
    create_table :transactables do |t|
      t.string :name
      t.integer :instance_type_id
      t.integer :instance_id
      t.integer :partner_id
      t.integer :creator_id
      t.integer :company_id
      t.integer :location_id
      t.integer :listing_type_id
      t.integer :administrator_id
      t.text :description

      t.hstore :properties
      t.datetime :deleted_at
      t.datetime :draft
      t.datetime :activated_at
      t.boolean :listings_public
      t.boolean :enabled
      t.text :metadata
      t.timestamps
    end
    execute "CREATE INDEX transactables_gin_properties ON transactables USING GIN(properties)"

    add_column :instance_types, :product_type, :string
    add_column :instances, :transactable_properties_types, :text
    add_column :instances, :transactable_properties_defaults, :text
    add_column :instances, :transactable_properties_validation_rules, :text

    rename_column :inquiries, :listing_id, :transactable_id
    rename_column :photos, :listing_id, :transactable_id
    rename_column :reservations, :listing_id, :transactable_id
    rename_column :unit_prices, :listing_id, :transactable_id

  end

  def down
    drop_table :transactables
    remove_column :instance_types, :product_type
    remove_column :instances, :transactable_properties_types
    remove_column :instances, :transactable_properties_defaults
    remove_column :instances, :transactable_properties_validation_rules

    rename_column :inquiries, :transactable_id, :listing_id
    rename_column :photos, :transactable_id, :listing_id
    rename_column :reservations, :transactable_id, :listing_id
    rename_column :unit_prices, :transactable_id, :listing_id
  end
end
