class AddDeletedAtToWebhook < ActiveRecord::Migration
  def change
    add_column :webhooks, :deleted_at, :datetime
  end
end
