class UserMessagesDecorator < Draper::CollectionDecorator
  include Draper::LazyHelpers

  def initialize(collection, user)
    @user = user
    super(collection)
  end

  def inbox
    @threaded_user_messages = threaded_user_messages.reject do |_key, user_messages|
      # reject all threads that have all messages archived for @user
      user_messages.all? { |user_message| user_message.archived_for?(@user) }
    end
    self
  end

  def unread
    @threaded_user_messages = threaded_user_messages.select do |_key, user_messages|
      # is in thread at least one message that is unread for @user
      user_messages.any? { |user_message| user_message.unread_for?(@user) }
    end
    self
  end

  def archived
    @threaded_user_messages = threaded_user_messages.select do |_key, user_messages|
      user_messages.all? { |user_message| user_message.archived_for?(@user) }
    end
    self
  end

  def fetch
    threaded_user_messages
  end

  def mark_as_read_for(user)
    # All unread messages are marked as read
    to_mark_as_read = decorated_collection.select { |m| m.unread_for?(user) }
    if to_mark_as_read.present?
      to_mark_as_read.each do |message|
        message.mark_as_read_for!(user)
      end

      # User who has seen this user message thread must have refreshed its unread counter cache
      # if there are some messages newly marked as read
      to_mark_as_read.first.update_unread_message_counter_for(user)
    end
  end

  def user_message_navigation_link(action, current_action, &block)
    link_class = 'btn btn-medium btn-gray'
    link_class += (current_action.to_sym == action) ? ' active' : '-darker'
    path = case action
    when :index
      dashboard_user_messages_path
    when :archived
      archived_dashboard_user_messages_path
    end
    link_to(path, class: link_class, &block)
  end

  def user_message_context_link(user_message)
    thread_context = user_message.thread_context
    if thread_context
      thread_context.decorate.user_message_summary(user_message)
    else
      user_message.thread_context_with_deleted.try(:name)
    end
  end

  private

  def threaded_user_messages
    @threaded_user_messages ||= decorated_collection.group_by(&:thread_scope).sort_by { |_key, user_messages| user_messages.last.created_at }.reverse
  end
end
