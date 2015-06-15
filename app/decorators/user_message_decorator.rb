class UserMessageDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::PolymorphicRoutes
  delegate_all

  def recipient_name
    recipient.first_name
  end

  def css_class(user = nil)
    classes = []
    classes << (read_for?(user) ? 'read' : 'unread')
    if user
      if author == user
        classes << 'my-message striped'
      else
        classes << 'foreign-message'
      end
    end
    classes.join(' ')
  end

  def available_for_reply?
    thread_context.present? && thread_owner.present? && thread_recipient.present?
  end

  def create_path(um = nil)
    um ||= self.object
    if Transactable === self.thread_context
      listing_user_messages_path(self.thread_context)
    else
      polymorphic_path([self.thread_context, um])
    end
  end

  def show_path(options = {})
    thread_context_with_deleted = self.thread_context_type.constantize.respond_to?(:with_deleted) ? self.thread_context_type.constantize.with_deleted.find(self.thread_context_id) : self.thread_context
    if Transactable === thread_context_with_deleted
      listing_user_message_path(thread_context_with_deleted, self.object, options)
    else
      polymorphic_path([thread_context_with_deleted, self.object], options)
    end
  end

  def archive_path(options = {})
    thread_context_with_deleted = self.thread_context_type.constantize.respond_to?(:with_deleted) ? self.thread_context_type.constantize.with_deleted.find(self.thread_context_id) : self.thread_context
    if Transactable === thread_context_with_deleted
      listing_user_message_archive_path(thread_context_with_deleted, self.object, options)
    else
      polymorphic_path([thread_context_with_deleted, self.object, :archive], options)
    end
  end


end
