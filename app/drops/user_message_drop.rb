class UserMessageDrop < BaseDrop

  attr_reader :user_message

  # body
  #   contents of the message
  # thread_context
  #  conversation context: a listing, a reservation, a user
  # recipient_name
  #   first name of the recipient
  delegate :body, :thread_context, :recipient_name, :create_path, to: :user_message

  def initialize(user_message)
    @user_message = user_message.decorate
  end

  # url to the section in the app for viewing the message
  # includes authentication token
  def url
    routes.listing_user_message_path(@user_message.thread_context, @user_message, token_key => @user_message.recipient.temporary_token)
  end

  def show_path_with_token
    @user_message.show_path(:token => @user_message.recipient.temporary_token)
  end

  # url to the section in the app for viewing the message
  # includes authentication token and tracking
  def url_with_tracking
    routes.listing_user_message_path(@user_message.thread_context, @user_message, token_key => @user_message.recipient.temporary_token, :track_email_event => true)
  end

  # first name of the thread owner (user that started the conversation)
  def owner_first_name
    @user_message.thread_owner.first_name
  end

  # first name of the author (user that wrote this message)
  def author_first_name
    @user_message.author.first_name
  end

end

