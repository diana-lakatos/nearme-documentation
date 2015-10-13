class AddWorkflowsToUnreadMessages < ActiveRecord::Migration
  def change
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      Utils::DefaultAlertsCreator::UserCreator.new.create_unread_messages_email!
    end
  end
end
