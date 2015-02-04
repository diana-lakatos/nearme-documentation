class UserMessageDrop < BaseDrop

  attr_reader :user_message
  delegate :body, to: :user_message

  def initialize(user_message)
    @user_message = user_message.decorate
  end

  def url
    routes.listing_user_message_path(@user_message.thread_context, @user_message, :token => @user_message.recipient.temporary_token)
  end

  def show_path_with_token
    @user_message.show_path(:token => @user_message.recipient.temporary_token)
  end

  def url_with_tracking
    routes.listing_user_message_path(@user_message.thread_context, @user_message, :token => @user_message.recipient.temporary_token, :track_email_event => true)
  end

  def owner_first_name
    @user_message.thread_owner.first_name
  end

  def author_first_name
    @user_message.author.first_name
  end

end
