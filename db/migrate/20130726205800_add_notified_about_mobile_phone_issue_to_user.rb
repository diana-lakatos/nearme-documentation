class AddNotifiedAboutMobilePhoneIssueToUser < ActiveRecord::Migration

  def change
    add_column :users, :notified_about_mobile_number_issue_at, :datetime
  end

end
