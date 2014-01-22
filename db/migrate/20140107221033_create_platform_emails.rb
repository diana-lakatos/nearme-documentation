class CreatePlatformEmails < ActiveRecord::Migration
  def change
    create_table :platform_emails do |t|
      t.string :email
      t.datetime :notified_at
      t.datetime :unsubscribed_at
      t.timestamps
    end
  end
end
