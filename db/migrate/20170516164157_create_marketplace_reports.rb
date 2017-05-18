class CreateMarketplaceReports < ActiveRecord::Migration
  def change
    create_table :marketplace_reports do |t|
      t.integer :instance_id

      t.string :report_type
      t.integer :creator_id
      t.text :zip_file
      t.string :state
      t.text :error
      t.text :report_parameters

      t.timestamp :deleted_at
      t.timestamps
    end

    add_index :marketplace_reports, :instance_id
  end
end
