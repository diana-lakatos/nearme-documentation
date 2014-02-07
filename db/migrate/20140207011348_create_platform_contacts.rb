class CreatePlatformContacts < ActiveRecord::Migration
  def change
    create_table :platform_contacts do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :comments
      t.boolean :subscribed, default: false

      t.timestamps
    end
  end
end
