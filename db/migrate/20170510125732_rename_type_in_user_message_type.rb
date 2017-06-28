class RenameTypeInUserMessageType < ActiveRecord::Migration
  def change
    rename_column :user_message_types, :type, :message_type
  end
end
