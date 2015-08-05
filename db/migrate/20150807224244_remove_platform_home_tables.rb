class RemovePlatformHomeTables < ActiveRecord::Migration
  def up
    drop_table :platform_contacts
    drop_table :platform_demo_requests
    drop_table :platform_emails
    drop_table :platform_inquiries
  end
end
