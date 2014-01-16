class UserMessagesController < ApplicationController

  before_filter :set_message_context!, except: [:index, :archived]
  before_filter :redirect_to_login, only: [:new]
  before_filter :authenticate_user!, except: [:new]
  before_filter :set_user_messages_decorator

  def index
    @threaded_user_messages = @user_messages_decorator.inbox.fetch
  end

  def archived
    @threaded_user_messages = @user_messages_decorator.archived.fetch
    render :index
  end

  def new
    @user_message = @message_context.user_messages.new
    setup_user_message
  end

  def create
    @user_message = @message_context.user_messages.new(params[:user_message])
    setup_user_message
    if @user_message.save
      # User who is recipient of this listing message thread must have refreshed its unread counter cache
      set_unread_message_counters_for(@user_message.recipient)

      @user_message.send_notification(platform_context)
      flash[:notice] = t('flash_messages.user_messages.message_sent')
      redirect_to user_messages_path
      render_redirect_url_as_json if request.xhr?
    else
      if request.xhr?
        render :template => 'user_messages/new'
      else
        @displayed_user_message = @user_message
        @user_messages = UserMessage.for_thread(@user_message.thread_owner, @user_message.thread_recipient, @user_message.thread_context || @user_message.thread_context_with_deleted).by_created.decorate
        render :show
      end
    end
  end

  def show
    @displayed_user_message = @message_context.user_messages.find(params[:id])
    @user_message = @message_context.user_messages.new(replying_to_id: @displayed_user_message.id)

    @user_messages = UserMessage.for_thread(@displayed_user_message.thread_owner, @displayed_user_message.thread_recipient, @displayed_user_message.thread_context || @displayed_user_message.thread_context_with_deleted).by_created.decorate

    # All unread messages are marked as read
    to_mark_as_read = @user_messages.select{|m| m.unread_for?(current_user)}
    UserMessage.update_all({read: true},
                              {id: to_mark_as_read.map(&:id)})

    # User who has seen this user message thread must have refreshed its unread counter cache
    # if there are some messages newly marked as read
    set_unread_message_counters_for(current_user) if to_mark_as_read.present?

    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def archive
    @user_message = @message_context.user_messages.find(params[:user_message_id])
    column = @user_message.archived_column_for(current_user)
    UserMessage.update_all({column => true},
                              { thread_owner_id: @user_message.thread_owner_id, 
                                thread_recipient_id: @user_message.thread_recipient_id, 
                                thread_context_id: @user_message.thread_context_id,
                                thread_context_type: @user_message.thread_context_type})
    flash[:notice] = t('flash_messages.user_messages.message_archived')
    redirect_to user_messages_path
  end

  private

  def set_user_messages_decorator
    @user_messages_decorator = UserMessagesDecorator.new(current_user.user_messages, current_user)
  end

  def redirect_to_login
    return if user_signed_in?
    session[:user_return_to] = request.referrer
    redirect_to new_user_session_path
  end

  def set_message_context!
    @message_context = nil

    path_spec = Rails.application.routes.router.recognize(request) { |route, _| route.name }.flatten.last.path.spec.to_s.gsub(/\([^\)]*\)/, '')
    if path_spec.include?('listings')
      listing_scope = ['show', 'archive'].include?(action_name) ? Listing.with_deleted : Listing.scoped
      @message_context = listing_scope.find(params[:listing_id])
    end

    if path_spec.include?('users')
      user_scope = ['show', 'archive'].include?(action_name) ? User.with_deleted : User.scoped
      @message_context = user_scope.find(params[:user_id])
    end

    if path_spec.include?('reservations')
      reservation_scope = ['show', 'archive'].include?(action_name) ? Reservation.with_deleted : Reservation.scoped
      @message_context = reservation_scope.find(params[:reservation_id])
    end

    # no context found or user is not allowed to join this conversation
    if @message_context.nil? || !current_user.has_access_to_message_context?(@message_context)
      redirect_to root_path
      render_redirect_url_as_json if request.xhr?
    end
  end

  def setup_user_message
    @user_message.author = current_user
    @user_message.thread_owner = if @user_message.first_in_thread?
      current_user
    else
      @user_message.previous_in_thread.thread_owner
    end
    @user_message.thread_recipient = if @user_message.first_in_thread?
      case @message_context
      when Listing
        @message_context.administrator
      when User
        @message_context
      when Reservation
        @message_context.owner
      end
    else
      @user_message.previous_in_thread.thread_recipient
    end 
    @user_message.thread_context = @message_context
    @user_message = @user_message.decorate
  end

  def set_unread_message_counters_for(user)
    actual_count = user.reload.decorate.unread_user_message_threads.fetch.size
    user.unread_user_message_threads_count = actual_count
    user.save!
  end
end
