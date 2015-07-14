class CreateMarketplaceErrors < ActiveRecord::Migration
  def change
    create_table :marketplace_errors do |t|
      t.integer :instance_id, index: true
      t.string :error_type
      t.text :message
      t.text :stacktrace
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
