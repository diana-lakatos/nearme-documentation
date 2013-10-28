class ListingMessageDecorator < Draper::Decorator
  delegate_all

  def recipient_name
    owner_id == author_id ? listing.name : owner.name
  end

  def css_class(user = nil)
    classes = []
    classes << (read? ? 'read' : 'unread')
    if user
      if author == user
        classes << 'my-message'
      else
        classes << 'foreign-message'
      end
    end
    classes.join(' ')
  end

end
