class ListingMessageDecorator < Draper::Decorator
  delegate_all

  def recipient_name
    owner_id == author_id ? listing.name : owner.name
  end

  def css_class
    read? ? 'read' : 'unread'
  end

end
