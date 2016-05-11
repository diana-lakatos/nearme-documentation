class CreateShippingProfiles < ActiveRecord::Migration
  def change
    create_table :shipping_profiles do |t|
      t.integer :instance_id, index: true
      t.string :name
      t.datetime :deleted_at
      t.integer :company_id
      t.integer :partner_id
      t.integer :user_id
      t.boolean :global

      t.timestamps null: false
      t.index [:instance_id, :company_id]
    end
  end
end
