class CreateSearchNotifications < ActiveRecord::Migration
  def change
    create_table :search_notifications do |t|
      t.string :email
      t.integer :user_id
      t.string :query
      t.float :latitude
      t.float :longitude
      t.boolean :notified, default: false

      t.timestamps
    end
  end
end
