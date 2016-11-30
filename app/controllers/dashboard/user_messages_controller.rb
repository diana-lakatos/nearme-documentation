# frozen_string_literal: true
class Dashboard::UserMessagesController < Dashboard::BaseController
  before_action :redirect_to_login, only: [:new]
  skip_before_action :authenticate_user!, only: [:new]

  before_action :missing_phone_number, only: [:new], unless: proc { params[:skip] || current_user.mobile_number.present? }

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

    # if recipient is not valid, @user_message.save will fail, despite all is fine
    # hence current_user.save!
    if @user_message.valid? && current_user.save!
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
        @user_messages = UserMessage.for_thread(*for_thread_arguments(@user_message)).by_created.decorate
        render :show
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

    @user_messages = UserMessage.for_thread(*for_thread_arguments(@user_message)).by_created.decorate
    @user_messages.mark_as_read_for(current_user)
  end

  def archive
    @displayed_user_message = current_user.user_messages.find(params[:user_message_id])

    @user_messages = UserMessage.for_thread(*for_thread_arguments(@displayed_user_message))
                                .find_each { |um| um.archive_for!(current_user) }
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

  def missing_phone_number
    @country = current_user.country_name
    if params[:listing_id].present? || params[:transactable_id].present?
      @return_path = new_listing_user_message_path(params[:listing_id] || params[:transactable_id], skip: true)
    elsif params[:user_id].present?
      @return_path = new_user_user_message_path(params[:user_id], skip: true)
    elsif params[:reservation_id].present?
      @return_path = new_reservation_user_message_path(params[:reservation_id], skip: true)
    end

    render :missing_phone_number
  end

  def order_messages(collection)
    collection.sort! { |a, b| [a.last.last.the_other_user(current_user).name, a.last.last.created_at.to_i * -1] <=> [b.last.last.the_other_user(current_user).name, b.last.last.created_at.to_i * -1] } if params[:order_way] == 'author_name'
    collection
  end

  def for_thread_arguments(user_message)
    [
      [
        user_message.thread_owner,
        user_message.thread_recipient,
        user_message.author
      ].uniq.map(&:id),
      user_message.thread_context_with_deleted
    ]
  end
end
