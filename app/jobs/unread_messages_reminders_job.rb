class UnreadMessagesRemindersJob < Job

  def perform
    Instance.find_each do |i|
      i.set_context!

      UsersWithUnreadMessagesFinder.new.find.each do |user|
        WorkflowStepJob.perform(WorkflowStep::UserWorkflow::UnreadMessages, user.id)
        user.user_messages.update_all(unread_last_reminded_at: Time.now)
      end
    end
  end

end
