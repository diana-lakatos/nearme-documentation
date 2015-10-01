class CreateCommentSpamReports < ActiveRecord::Migration
  def change
    create_table :comment_spam_reports do |t|
      t.integer :user_id
      t.integer :comment_id
      t.integer :instance_id
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :comment_spam_reports, :user_id
    add_index :comment_spam_reports, :instance_id
    add_index :comment_spam_reports, :comment_id
  end
end
