class AddInstanceUnreadMessageThreadsCountToUser < ActiveRecord::Migration

  class Instance < ActiveRecord::Base
  end

  class User < ActiveRecord::Base
    def user_messages
      UserMessage.for_user(self)
    end
  end

  class UserMessage < ActiveRecord::Base
    belongs_to :author, class_name: 'User'           # person that wrote this message
    belongs_to :thread_owner, class_name: 'User'     # user that started conversation
    belongs_to :thread_recipient, class_name: 'User' # user that is conversation recipient
    belongs_to :thread_context, polymorphic: true    # conversation context: Listing, Reservation, User
    belongs_to :instance

    scope :for_user, ->(user) {
      where('thread_owner_id = ? OR thread_recipient_id = ?', user.id, user.id).order('user_messages.created_at asc')
    }

    def thread_scope
      [thread_owner_id, thread_recipient_id, thread_context_id, thread_context_type]
    end

    def read_column_for(user)
      "read_for_#{kind_for(user)}"
    end

    def read_for?(user)
      send read_column_for(user)
    end

    def unread_for?(user)
      !read_for?(user)
    end

    private

    def kind_for(user)
      user.id == thread_owner_id ? :owner : :recipient
    end
  end

  def get_unread_user_message_threads_grouped_by_instance_for(user)
    threaded = user.user_messages.group_by{|user_message|
      user_message.thread_scope + [user_message.instance_id]
    }.sort_by{|key, user_messages| user_messages.last.created_at }.reverse
    
    # inbox
    threaded = threaded.reject {|key, user_messages|
      user_messages.all?{|user_message|
        if user.id == user_message.thread_owner_id
          user_message.archived_for_owner
        else
          user_message.archived_for_recipient
        end
      }
    }

    # unread
    threaded = threaded.select { |key, user_messages|
      user_messages.any?{|user_message| user_message.unread_for?(user) && user.id != user_message.author_id }
    }

    Hash[Hash[threaded].values.flatten.group_by(&:instance_id).map{|k, v| [k, v.size]}]
  end

  def up
    add_column :users, :instance_unread_messages_threads_count, :text, default: {}

    User.all.each do |user|
      next if user.user_messages.empty?
      threads_count = get_unread_user_message_threads_grouped_by_instance_for(user)
      user.update_column(:instance_unread_messages_threads_count, threads_count.to_yaml)
    end

    remove_column :users, :unread_user_message_threads_count
  end

  def down
    remove_column :users, :instance_unread_messages_threads_count
    add_column :users, :unread_user_message_threads_count, :integer, default: 0
  end
end
