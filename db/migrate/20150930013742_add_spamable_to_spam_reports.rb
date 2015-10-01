class AddSpamableToSpamReports < ActiveRecord::Migration
  def change
    rename_table :comment_spam_reports, :spam_reports
    rename_column :spam_reports, :comment_id, :spamable_id
    add_column :spam_reports, :spamable_type, :string

    SpamReport.update_all spamable_type: "Comment"
  end
end
