# frozen_string_literal: true
class CreateUnreadUserMessageSpacerWorkflow < ActiveRecord::Migration
  class SpacerUserMessageCreator < Utils::DefaultAlertsCreator::WorkflowCreator
    def create_user_message_created_api!
      create_alert!(
        associated_class: WorkflowStep::UserMessageWorkflow::Created,
        name: 'unread_user_message_api',
        alert_type: 'api_call',
        recipient_type: 'Administrator',
        endpoint: 'https://hooks.slack.com/services/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'
      )
    end

    protected

    def workflow_type
      'user_message'
    end
  end

  def up
    Instances::InstanceFinder.get(:spacerau, :spacercom).each do |i|
      i.set_context!
      workflow_alert = SpacerUserMessageCreator.new.create_user_message_created_api!
      workflow_alert.update_attributes!(
        use_ssl: true,
        request_type: 'POST',
        delay: 1440,
        prevent_trigger_condition: 'user_message.replied? or user_message.thread_context_type != Transactable',
        payload_data: '{"text": " ---- Message not responded  --- \n\n*Recipient:* {{ user.email }}\n *Sender:* {{ author.email }}\n *Listing:* {{ listing.name }}\n *Created At:* {{ user_message.created_at }}\n *Receiver:* {% if user.id == listing.creator_id %}Host{%else%}Guest{%endif%}\n *Message:* {{ user_message.body }}\n"}'
      )
    end
  end

  def down
  end
end
