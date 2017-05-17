class AddUserMessagesToDevmesh < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:devmesh).each do |i|
      i.set_context!

      query = i.graph_queries.find_or_initialize_by(name: 'user_message_conversation')
      query.query_string = <<EOQ
query conversation($user_id: ID!, $thread_id: ID!){
    user(id: $user_id){
      thread(id: $thread_id) {
        participant{
         id
        first_name
        last_name
        avatar{
          thumb: url(version: "thumb")
        }
      }
      messages{
        author{
          id
          first_name
          last_name
          avatar{
            thumb: url(version: "thumb")
          }
        }
        created_at
        body
        attachments {
          name
          url
        }
      }
    }
  }
}
EOQ
    query.save!

    query = i.graph_queries.find_or_initialize_by(name: 'conversation_threads_for_user')
    query.query_string = <<EOQ
query conversationThreadsForUser($user_id: ID!){
  user(id: $user_id) {
    threads: threads {
      is_read
      url
      participant{
        first_name
        last_name
        avatar{
          thumb: url(version: "thumb")
        }
      }
      last_message{
        body
        created_at
      }
    }
  }
}
EOQ
      query.save!


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
        { key: 'user_messages.submit_hint', value: 'Press enter to send message' },
        { key: 'user_messages.trigger_button', value: 'Message' }
      ]

      ts.each do |t|
        i.translations.where(locale: 'en', key: t[:key])
                      .first_or_initialize
                      .update!(value: t[:value])
      end
    end
  end

  def down
  end
end
