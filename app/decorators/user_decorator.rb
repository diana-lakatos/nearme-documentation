class UserDecorator < Draper::Decorator
  delegate_all

  def job_title_and_company_name
    result = []
    result << job_title if job_title.present?
    result << company_name if company_name.present?
    result.join(" at ")
  end

  def current_location_and_industry
    result = []
    result << current_location if current_location.present?
    result << industries.map(&:name).join(", ") if industries.present?
    result.join(" | ")
  end

  def unread_user_message_threads
    user_messages_decorator.inbox.unread
  end

  def social_connections_for(provider)
    social_connections_cache.select{|c| c.provider == provider}.first
  end

  private

  def user_messages_decorator
    @user_messages_decorator ||= UserMessagesDecorator.new(user_messages, object)
  end

  def social_connections_cache
    @social_connections_cache ||= self.social_connections
  end
end
