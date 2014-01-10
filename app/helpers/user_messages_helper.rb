module UserMessagesHelper

  def user_message_navigation_link(action, &block)
    link_class = "btn btn-medium btn-gray"
    link_class += (params[:action].to_sym == action) ? ' active' : '-darker'
    path = case action
    when :index
      user_messages_path
    when :archived
      archived_user_messages_path
    end
    link_to(path, class: link_class, &block)
  end

  def user_message_context_link(user_message)
    thread_context = user_message.thread_context
    if thread_context
      case thread_context
      when Listing
        link_to thread_context.name, location_listing_path(thread_context.location, thread_context)
      when User
        link_to thread_context.name, profile_path(thread_context.slug)
      when Reservation
        link_to thread_context.name, location_listing_path(thread_context.location, thread_context.listing)
      end
    else
      user_message.thread_context_with_deleted.try(:name)
    end
  end
end
