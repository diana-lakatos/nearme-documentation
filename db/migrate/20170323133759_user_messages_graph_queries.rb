# frozen_string_literal: true
class UserMessagesGraphQueries < ActiveRecord::Migration
  def up
    # hallmark
    i = Instance.find_by(id: 5011)
    # this will work only on oregon
    return unless i
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
    query.save

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
    query.save
  end

  def down
  end
end
