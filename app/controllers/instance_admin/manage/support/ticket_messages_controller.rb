class InstanceAdmin::Manage::Support::TicketMessagesController < InstanceAdmin::Manage::BaseController
  def create
    message = Support::TicketMessage.new(ticket_params)
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

  def permitting_controller_class
    'support'
  end

  private

  def ticket
    @ticket ||= Support::Ticket.find(params[:ticket_id])
  end

  def close?
    params[:commit] == "Update and Resolve"
  end

  def ticket_params
    params[:support_ticket_message].merge(
      user: current_user,
      ticket: ticket
    )
  end
end
