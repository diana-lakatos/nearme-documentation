class Dashboard::UserMessagesController < Dashboard::BaseController
  before_filter :redirect_to_login, only: [:new]
  skip_before_filter :authenticate_user!, only: [:new]

  before_filter :missing_phone_number, only: [:new], unless: proc { params[:skip] || current_user.mobile_number.present? }

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
    @user_message.set_message_context_from_request_params(params)
    render partial: 'form'
  end

  def create
    @user_message = current_user.authored_messages.new(message_params).decorate
    @user_message.set_message_context_from_request_params(params)

    if @user_message.save
      @user_message.send_notification

      if request.xhr?
        unless @user_message.first_in_thread?
          render partial: 'user_message_for_show', locals: { user_message: @user_message }
        else
          flash[:notice] = t('flash_messages.user_messages.message_sent')
          redirect_to dashboard_user_message_path(@user_message)
          render_redirect_url_as_json
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
        @user_messages = UserMessage.for_thread(@user_message.thread_owner_with_deleted, @user_message.thread_recipient_with_deleted, @user_message.thread_context_with_deleted).by_created.decorate
        render :show
      end
    end
  end

  def show
    @displayed_user_message = current_user.user_messages.find(params[:id]).decorate
    @user_message = current_user.authored_messages.new(replying_to_id: @displayed_user_message.id)
    @user_messages = UserMessage.for_thread(@displayed_user_message.thread_owner_with_deleted, @displayed_user_message.thread_recipient_with_deleted, @displayed_user_message.thread_context_with_deleted).by_created.decorate
    @user_messages.mark_as_read_for(current_user)

    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def archive
    @user_message = current_user.user_messages.find(params[:user_message_id])
    @user_message.archive_for!(current_user)

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
    session[:user_return_to] = request.referrer
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
end
