class UserMessageThreadConfigurator

  AVAILABLE_CONTEXTS = [Transactable, User, Reservation, RecurringBooking, Purchase, DelayedReservation]

  def initialize(user_message, request_params)
    @user_message = user_message
    @request_params = request_params
  end

  def run
    find_message_context
    set_thread_owner
    set_thread_recipient
  end

  private

  def find_message_context
    @message_context = nil

    AVAILABLE_CONTEXTS.each do |context_class|
      context_id_key = context_class.to_s.foreign_key.to_sym
      context_id_key = :listing_id if context_id_key == :transactable_id

      if @request_params[context_id_key].present?
        @message_context = context_class.with_deleted
        @message_context = @message_context.friendly if @message_context.respond_to?(:friendly)
        @message_context = @message_context.find(@request_params[context_id_key]).decorate
      end
    end

    raise DNM::MessageContextNotAvailable if @message_context.nil?
  end

  def set_thread_owner
    @user_message.thread_owner = if @user_message.first_in_thread?
      @user_message.author
    else
      @user_message.previous_in_thread.thread_owner
    end

    @user_message.thread_context = @message_context.try(:object)

    raise DNM::MessageContextNotAvailable if !@user_message.author_has_access_to_message_context?
  end

  def set_thread_recipient
    @user_message.thread_recipient = @message_context.user_message_recipient
  end
end
