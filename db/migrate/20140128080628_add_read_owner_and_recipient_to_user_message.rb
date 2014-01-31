class AddReadOwnerAndRecipientToUserMessage < ActiveRecord::Migration

  class UserMessage < ActiveRecord::Base
  end

  def up
    add_column :user_messages, :read_for_owner, :boolean, default: false
    add_column :user_messages, :read_for_recipient, :boolean, default: false

    UserMessage.all.each do |message|
      message.update_column(:read_for_recipient, message.read)
      message.update_column(:read_for_owner, message.read)
    end

    remove_column :user_messages, :read
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
