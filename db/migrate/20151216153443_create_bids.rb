class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :offer_id, index: true
      t.integer :user_id, index: true
      t.integer :instance_id, index: true
      t.string :state
      t.hstore :properties

      t.timestamp :deleted_at
      t.timestamps null: false
    end
  end
end
