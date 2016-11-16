class UserMessageDrop < BaseDrop

  # @return [UserMessageDrop]
  attr_reader :user_message

  # @!method id
  #   @return [Integer] numeric identifier for the object
  # @!method body
  #   Contents of the message
  #   @return (see UserMessage#body)
  # @!method thread_context
  #   @return [Object] Conversation context: a listing, a booking, a user etc.
  # @!method recipient_name
  #   @return (see UserMessageDecorator#recipient_name)
  # @!method create_path
  #   @return (see UserMessageDecorator#create_path)
  delegate :id, :body, :thread_context, :recipient_name, :create_path, to: :user_message

  def initialize(user_message)
    @user_message = user_message.decorate
  end

  # @return [String] url to the section in the app for viewing the message - includes authentication token
  # @todo Path/url inconsistency
  def url
    routes.listing_user_message_path(@user_message.thread_context, @user_message, token_key => @user_message.recipient.temporary_token)
  end

  # @return [String] path to this user message in the app
  def show_path_with_token
    @user_message.show_path(token: @user_message.recipient.temporary_token)
  end

  # @return [String] path to the section in the app for viewing the message; includes authentication token and tracking
  # @todo Path/url inconsistency
  def url_with_tracking
    routes.listing_user_message_path(@user_message.thread_context, @user_message, token_key => @user_message.recipient.temporary_token)
  end

  # @return [String] first name of the thread owner (user that started the conversation)
  def owner_first_name
    @user_message.thread_owner.first_name
  end

  # @return [String] first name of the author (user that wrote this message)
  def author_first_name
    @user_message.author.first_name
  end

  # @return [Boolean] whether this message is archived for the currently logged in user
  def archived_for_current_user?
    @user_message.archived_for?(@context['current_user'])
  end
end
