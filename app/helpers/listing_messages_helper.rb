module ListingMessagesHelper

  def listing_message_navigation_link(action, &block)
    link_class = "btn btn-medium btn-gray"
    link_class += (params[:action].to_sym == action) ? ' active' : '-darker'
    path = case action
    when :index
      listing_messages_path
    when :archived
      archived_listing_messages_path
    end
    link_to(path, class: link_class, &block)
  end

end
