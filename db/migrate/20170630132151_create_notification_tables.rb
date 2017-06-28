# frozen_string_literal: true
class CreateNotificationTables < ActiveRecord::Migration
  def change
    create_table :email_notifications do |t|
      t.string :name, null: false
      t.text :to, null: false
      t.text :content, null: false
      t.integer :delay, default: 0
      t.integer :instance_id, null: false
      t.timestamps
      t.datetime :deleted_at
      t.index [:instance_id, :name], unique: true, using: :btree, where: '(deleted_at IS NULL)'
      t.boolean :enabled, default: true
      t.text :trigger_condition, default: 'true'
      t.string :locale
      t.string :time_zone
      t.string :from, null: false
      t.string :reply_to
      t.text :cc
      t.text :bcc
      t.text :subject
      t.string :layout_path
    end
    create_table :sms_notifications do |t|
      t.string :name, null: false
      t.text :to, null: false
      t.text :content, null: false
      t.integer :delay, default: 0
      t.integer :instance_id, null: false
      t.timestamps
      t.datetime :deleted_at
      t.index [:instance_id, :name], unique: true, using: :btree, where: '(deleted_at IS NULL)'
      t.boolean :enabled, default: true
      t.text :trigger_condition, default: 'true'
      t.string :locale
      t.string :time_zone
    end
    create_table :api_call_notifications do |t|
      t.string :name, null: false
      t.text :to, null: false
      t.text :content, null: false
      t.string :format, null: false, default: 'http'
      t.integer :delay, default: 0
      t.integer :instance_id, null: false
      t.timestamps
      t.datetime :deleted_at
      t.index [:instance_id, :name], unique: true, using: :btree, where: '(deleted_at IS NULL)'
      t.boolean :enabled, default: true
      t.text :trigger_condition, default: 'true'
      t.string :locale
      t.string :time_zone
      t.string :request_type, default: 'POST', null: false
      t.text :headers, default: '{}'
    end
    create_table :form_configuration_notifications do |t|
      t.integer :instance_id, null: false
      t.integer :form_configuration_id, null: false
      t.integer :notification_id, null: false
      t.string :notification_type, null: false
      t.timestamps
      t.index [:instance_id, :form_configuration_id, :notification_id, :notification_type],
              unique: true, name: 'index_on_form_configuration_notifications_unique'
    end
  end
end
