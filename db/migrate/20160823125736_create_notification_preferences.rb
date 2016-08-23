class CreateNotificationPreferences < ActiveRecord::Migration
  def change
    create_table :notification_preferences do |t|
      t.integer  :instance_id
      t.integer  :user_id
      t.boolean  :project_updates_enabled, default: true
      t.boolean  :group_updates_enabled, default: true
      t.string   :email_frequency, default: 'immediately'

      t.timestamps null: false
      t.index [:instance_id, :user_id], unique: true
    end
  end
end
