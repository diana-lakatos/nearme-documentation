class InstanceAdmin::Manage::Support::TicketMessagesController < InstanceAdmin::Manage::BaseController
  skip_before_filter :check_if_locked
  def create
    message = Support::TicketMessage.new(params[:support_ticket_message])
    message.user = current_user
    message.ticket = ticket
    if message.save
      SupportMailer.enqueue.request_replied(@ticket, message)
      flash[:success] = t('flash_messages.support.ticket_message.created')
    else
      flash[:error] = t('flash_messages.support.ticket_message.error') unless close?
    end

    if close?
      if ticket.resolve
        flash[:success] = t('flash_messages.support.ticket_message.closed')
      else
        flash[:error] = t('flash_messages.support.ticket_message.error')
      end
    end

    redirect_to instance_admin_manage_support_ticket_path(ticket)
  end

  private

  def permitting_controller_class
    'support'
  end

  def ticket
    @ticket ||= Support::Ticket.find(params[:ticket_id])
  end

  def close?
    params[:commit] == "Update and Resolve"
  end
end
