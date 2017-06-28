class PopulateUserMessageWithDefaultUserMessageType < ActiveRecord::Migration
  def change
    Instance.all.each do |instance|

      instance.set_context!

      next if UserMessageType.default

      message_type = UserMessageType.create!(message_type: UserMessageType::DEFAULT)
      UserMessage.where(user_message_type_id: nil)
                 .update_all(user_message_type_id: message_type.id)
    end
  end
end
