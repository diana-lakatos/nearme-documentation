class AddInstanceIdToUserMessage < ActiveRecord::Migration

  class UserMessage < ActiveRecord::Base
  end

  class Instance < ActiveRecord::Base
  end

  def change
    add_column :user_messages, :instance_id, :integer
    add_index :user_messages, :instance_id

    dnm_instance = Instance.find(1)
    if dnm_instance
      UserMessage.all.each do |user_message|
        user_message.update_column(:instance_id, dnm_instance.id)
      end
    end
  end
end
