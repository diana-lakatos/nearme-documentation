class UserMessagesController < ApplicationController

  before_filter :redirect_to_login, only: [:new]
  before_filter :authenticate_user!, except: [:new]

  helper_method :user_messages_decorator

  def index
    @threaded_user_messages = user_messages_decorator.inbox.fetch
  end

  def archived
    @threaded_user_messages = user_messages_decorator.archived.fetch
    render :index
  end

  def new
    @user_message = current_user.authored_messages.new.decorate
    @user_message.set_message_context_from_request_params(params)
  end

  def create
    @user_message = current_user.authored_messages.new(params[:user_message].merge(instance_id: platform_context.instance.id)).decorate
    @user_message.set_message_context_from_request_params(params)
    if @user_message.save
      @user_message.send_notification(platform_context)
      flash[:notice] = t('flash_messages.user_messages.message_sent')
      redirect_to user_messages_path
      render_redirect_url_as_json if request.xhr?
    else
      if request.xhr?
        render :template => 'user_messages/new'
      else
        @displayed_user_message = @user_message
        @user_messages = UserMessage.for_instance(platform_context.instance).for_thread(@user_message.thread_owner_with_deleted, @user_message.thread_recipient_with_deleted, @user_message.thread_context_with_deleted).by_created.decorate
        render :show
      end
    end
  end

  def show
    @displayed_user_message = current_user.user_messages.for_instance(platform_context.instance).find(params[:id]).decorate
    @user_message = current_user.authored_messages.new(replying_to_id: @displayed_user_message.id)

    @user_messages = UserMessage.for_instance(platform_context.instance).for_thread(@displayed_user_message.thread_owner_with_deleted, @displayed_user_message.thread_recipient_with_deleted, @displayed_user_message.thread_context_with_deleted).by_created.decorate
    @user_messages.mark_as_read_for(current_user)

    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def archive
    @user_message = current_user.user_messages.for_instance(platform_context.instance).find(params[:user_message_id])
    @user_message.archive_for!(current_user)

    flash[:notice] = t('flash_messages.user_messages.message_archived')
    redirect_to user_messages_path
  end

  private

  def user_messages_decorator
    @user_messages_decorator ||= UserMessagesDecorator.new(current_user.user_messages.for_instance(platform_context.instance), current_user)
  end

  def redirect_to_login
    return if user_signed_in?
    session[:user_return_to] = request.referrer
    redirect_to new_user_session_path
  end
end
