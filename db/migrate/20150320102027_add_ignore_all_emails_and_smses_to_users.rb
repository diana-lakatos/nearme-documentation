class AddIgnoreAllEmailsAndSmsesToUsers < ActiveRecord::Migration
  def up
    add_column :users, :accept_emails, :boolean, default: true
    User.where(accept_emails: nil).update_all(accept_emails: true)
  end

  def down
    remove_column :users, :accept_emails, :boolean
  end
end
