class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :name
      t.text :summary
      t.text :description
      t.integer :price_cents
      t.hstore :properties
      t.string :currency
      t.string :slug, index: true
      t.integer :instance_id, index: true
      t.integer :transactable_type_id, index: true
      t.integer :company_id, index: true
      t.integer :creator_id, index: true
      t.timestamp :draft_at
      t.timestamp :deleted_at

      t.timestamps null: false
    end
  end
end
