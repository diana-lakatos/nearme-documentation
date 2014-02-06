class AddInstanceIdToUserMessage < ActiveRecord::Migration

  class UserMessage < ActiveRecord::Base
  end

  class Instance < ActiveRecord::Base
    def self.default_instance
      self.find_by_default_instance(true)
    end
  end

  def change
    add_column :user_messages, :instance_id, :integer
    add_index :user_messages, :instance_id

    dnm_instance = Instance.default_instance
    if dnm_instance
      UserMessage.all.each do |user_message|
        user_message.update_column(:instance_id, dnm_instance.id)
      end
    end
  end
end
