class CreateExternalApiRequests < ActiveRecord::Migration
  def change
    create_table :external_api_requests do |t|
      t.references :context, polymorphic: true

      t.text :body
      t.integer :instance_id, index: true

      t.timestamps null: false
    end
  end
end
