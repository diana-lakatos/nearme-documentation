class AddSpamReviewedToSpamables < ActiveRecord::Migration
  def change
    add_column :activity_feed_events, :spam_ignored, :boolean, default: false
    add_column :comments, :spam_ignored, :boolean, default: false
  end
end
