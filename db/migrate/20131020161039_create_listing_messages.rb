class CreateListingMessages < ActiveRecord::Migration
  def change
    create_table :listing_messages do |t|
      t.integer :owner_id
      t.integer :author_id, null: false
      t.integer :listing_id
      t.text :body

      t.boolean :read, default: false
      t.boolean :archived_for_owner, default: false
      t.boolean :archived_for_listing, default: false

      t.timestamps
    end

    add_index :listing_messages, :listing_id
  end
end
