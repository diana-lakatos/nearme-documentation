class AddNotifiedAboutMobilePhoneIssueToUser < ActiveRecord::Migration

  def change
    add_column :users, :notified_about_mobile_number_issue, :boolean, :default => false
  end

end
