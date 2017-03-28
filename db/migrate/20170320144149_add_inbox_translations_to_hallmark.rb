# frozen_string_literal: true
class AddInboxTranslationsToHallmark < ActiveRecord::Migration
  def up
    i = Instance.find_by(id: 5011)
    return true if i.nil?
    i.set_context!

    ts = [
      { key: 'user_messages.topnav', value: 'Inbox ' },
      { key: 'user_messages.inbox_header', value: 'Messages ' },
      { key: 'user_messages.select_conversation', value: 'Select a conversation' },
      { key: 'user_messages.no_active_conversations', value: 'You have no active conversations.' },
      { key: 'user_messages.labels.body', value: 'Message' },
      { key: 'user_messages.placeholders.body_html', value: 'Leave a message&hellip;' },
      { key: 'user_messages.labels.attachment', value: 'Add file' },
      { key: 'user_messages.attachment', value: 'Attachment' },
      { key: 'user_messages.actions.send', value: 'Send message' },
      { key: 'user_messages.profile_link', value: 'Profile' },
      { key: 'user_messages.contact_list', value: 'Contact list' },
      { key: 'user_messages.message_meta_html', value: '<span data-user-messages-meta-author>%{user_name}</span> <time datetime="%{timestamp}">%{formatted_time}</time> says:' },
      { key: 'user_messages.submit_hint', value: 'Press enter to send message' }
    ]

    ts.each do |t|
      translation = Translation.where(locale: :en, key: t[:key], instance_id: 5011).first_or_initialize
      translation.value = t[:value]
      translation.save!
    end
  end

  def down
  end
end
