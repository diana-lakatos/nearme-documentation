class CreatePlatformDemoRequests < ActiveRecord::Migration
  def change
    create_table :platform_demo_requests do |t|
      t.string :name
      t.string :email
      t.string :company
      t.string :phone
      t.text :comments
      t.boolean :subscribed, default: false

      t.timestamps
    end
  end
end
