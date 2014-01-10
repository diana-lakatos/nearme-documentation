class UserMessageDecorator < Draper::Decorator
  delegate_all

  def recipient_name
    recipient.name
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
