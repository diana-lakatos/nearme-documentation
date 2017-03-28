# frozen_string_literal: true
class Dashboard::UserMessagesController < Dashboard::BaseController
  before_action :redirect_to_login, only: [:new]
  skip_before_action :authenticate_user!, only: [:new]

  helper_method :user_messages_decorator

  def index
    @threaded_user_messages = order_messages(user_messages_decorator.inbox.fetch)
  end

  def archived
    @threaded_user_messages = order_messages(user_messages_decorator.archived.fetch)
    render :index
  end

  def new
    @user_message = current_user.authored_messages.new.decorate
    @user_message.set_message_context_from_request_params(params, current_user)
    render partial: 'form'
  end

  def create
    @user_message = current_user.authored_messages.new(message_params).decorate
    @user_message.author = current_user
    @user_message.set_message_context_from_request_params(params, current_user)

    # so far use in Hallmark, should be made consistent across the board
    if params[:new_inbox].present?
      if @user_message.save
        @user_message.send_notification

        attachments = @user_message.attachments.map { |att| { url: att.file.url, name: att.file.file_name } }

        response = {
          author: @user_message.author.first_name,
          time: @user_message.created_at,
          body: @user_message.body,
          attachments: attachments
        }

        render json: response
      else
        render json: { error: @user_message.errors.messages.values.flatten.first }, status: 400
      end

    # used from modals and outside hallmark
    else
      # @user_messave.save will always succeed because in update_unread_message_counter_for we do
      # save(validate: false), so it will succeed even if the recipient is not valid
      if @user_message.save
        @user_message.send_notification

        if request.xhr?
          if @user_message.first_in_thread?
            flash[:notice] = t('flash_messages.user_messages.message_sent')
            redirect_to dashboard_user_message_path(@user_message)
            render_redirect_url_as_json
          else
            render partial: 'user_message_for_show', locals: { user_message: @user_message }
          end
        else
          flash[:notice] = t('flash_messages.user_messages.message_sent')
          redirect_to dashboard_user_message_path(@user_message)
        end

      else
        @error = @user_message.errors.messages.values.flatten.first
        if request.xhr?
          render partial: 'form'
        else
          @displayed_user_message = @user_message
          @user_messages = Messages::ForThreadQuery.new.call(@user_message).by_created.decorate
          render :show
        end
      end
    end
  end

  def show
    @displayed_user_message = current_user.user_messages.find(params[:id]).decorate
    @user_message = current_user.authored_messages.build(
      replying_to_id: @displayed_user_message.id,
      thread_recipient: @displayed_user_message.the_other_user(current_user),
      thread_context: @displayed_user_message.thread_context,
      thread_owner: @displayed_user_message.thread_owner
    )

    @user_messages = Messages::ForThreadQuery.new.call(@user_message).by_created.decorate
    @user_messages.mark_as_read_for(current_user)
  end

  def archive
    @displayed_user_message = current_user.user_messages.find(params[:user_message_id])

    @user_messages = Messages::ForThreadQuery.new.call(@displayed_user_message).find_each { |um| um.archive_for!(current_user) }
    @displayed_user_message.update_unread_message_counter_for(current_user)

    flash[:notice] = t('flash_messages.user_messages.message_archived')
    redirect_to dashboard_user_messages_path
  end

  private

  def user_messages_decorator
    @user_messages_decorator ||= UserMessagesDecorator.new(user_messages_scope, current_user)
  end

  def user_messages_scope
    initial_scope = current_user.user_messages
    if (@transactable = Transactable.find_by(id: params[:transactable_id]))
      initial_scope = initial_scope.for_transactable(@transactable)
    end
    initial_scope
  end

  def redirect_to_login
    return if user_signed_in?
    session[:user_return_to] = request.referer
    redirect_to new_user_session_path
  end

  def message_params
    params.require(:user_message).permit(secured_params.user_message)
  end

  def order_messages(collection)
    collection.sort! { |a, b| [a.last.last.the_other_user(current_user).name, a.last.last.created_at.to_i * -1] <=> [b.last.last.the_other_user(current_user).name, b.last.last.created_at.to_i * -1] } if params[:order_way] == 'author_name'
    collection
  end
end
