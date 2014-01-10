class UserMessagesDecorator < Draper::CollectionDecorator

  def initialize(collection, user)
    @user = user
    super(collection)
  end

  def inbox
    @threaded_user_messages = threaded_user_messages.reject {|key, user_messages|
      # reject all threads that have all messages archived for @user
      user_messages.all?{|user_message| user_message.archived_for?(@user) }
    }
    self
  end

  def unread
    @threaded_user_messages = threaded_user_messages.select { |key, user_messages|
      # is in thread at least one message that is unread for @user
      user_messages.any?{|user_message| user_message.unread_for?(@user) }
    }
    self
  end

  def archived
    @threaded_user_messages = threaded_user_messages.select { |key, user_messages|
      user_messages.all?{|user_message| user_message.archived_for?(@user) }
    }
    self
  end

  def fetch
    threaded_user_messages
  end

  private
  def threaded_user_messages
    @threaded_user_messages ||= decorated_collection.group_by{|user_message|
      user_message.thread_scope
    }.sort_by{|key, user_messages| user_messages.last.created_at }.reverse
  end

end
