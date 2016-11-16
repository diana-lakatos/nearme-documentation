class UserMessageDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::PolymorphicRoutes
  include ApplicationHelper
  delegate_all

  # @return [String] first name of the recipient of the message
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

  # @return [String] path to creating a new message in the thread of this message
  def create_path(um = nil)
    um ||= object
    if Transactable === thread_context
      listing_user_messages_path(thread_context)
    else
      polymorphic_path([thread_context, um])
    end
  end

  def show_path(options = {})
    thread_context_with_deleted = thread_context_type.constantize.respond_to?(:with_deleted) ? thread_context_type.constantize.with_deleted.find_by_id(thread_context_id) : thread_context
    # Edge case, will only happen if an admin has its admin permissions revoked and thus is no longer findable
    return '#' if thread_context_with_deleted.blank?

    if Transactable === thread_context_with_deleted
      listing_user_message_path(thread_context_with_deleted, object, options)
    else
      polymorphic_path([thread_context_with_deleted, object], options)
    end
  end

  def archive_path(options = {})
    thread_context_with_deleted = thread_context_type.constantize.respond_to?(:with_deleted) ? thread_context_type.constantize.with_deleted.find(thread_context_id) : thread_context
    if Transactable === thread_context_with_deleted
      listing_user_message_archive_path(thread_context_with_deleted, object, options)
    else
      polymorphic_path([thread_context_with_deleted, object, :archive], options)
    end
  end

  def body
    mask_phone_and_email_if_necessary(self[:body])
  end
end
