class CreateMarketplaceErrorGroups < ActiveRecord::Migration
  def change
    create_table :marketplace_error_groups do |t|
      t.integer :instance_id

      t.string :error_type
      t.text :message
      t.string :message_digest

      t.datetime :last_occurence

      t.integer :marketplace_errors_count, null: false, default: 0

      t.datetime :deleted_at
      t.timestamps
    end

    add_index :marketplace_error_groups, [:instance_id, :error_type, :message_digest], name: :meg_instance_type_digest, unique: true
  end
end
