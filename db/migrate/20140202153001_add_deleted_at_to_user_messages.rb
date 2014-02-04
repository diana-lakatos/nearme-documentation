class AddDeletedAtToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :deleted_at, :datetime
  end
end
