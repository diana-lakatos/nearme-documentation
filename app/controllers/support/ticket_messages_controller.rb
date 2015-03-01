class Support::TicketMessagesController < Support::BaseController
  def create
    message = Support::TicketMessage.new(message_params)
    message.user = current_user
    message.ticket = ticket
    if message.valid?
      message.save!
      if Transactable === ticket.target
        WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Updated, message.id)
        if ticket.target.action_free_booking?
          flash[:success] = t('flash_messages.support.rfq_ticket_message.created')
        else
          flash[:success] = t('flash_messages.support.offer_ticket_message.created')
        end
      else
        WorkflowStepJob.perform(WorkflowStep::SupportWorkflow::Updated, message.id)
        flash[:success] = t('flash_messages.support.ticket_message.created')
      end
    else
      unless close?
        if Transactable === ticket.target
          if ticket.target.action_free_booking?
            flash[:error] = t('flash_messages.support.rfq_ticket_message.error')
          else
            flash[:error] = t('flash_messages.support.offer_ticket_message.error')
          end
        else
          flash[:error] = t('flash_messages.support.ticket_message.error')
        end
      end

    end

    if close?
      if ticket.resolve
        flash[:success] = t('flash_messages.support.ticket_message.closed')
      else
        flash[:error] = t('flash_messages.support.ticket_message.error')
      end
    end

    redirect_to support_ticket_path(ticket)
  end

  private

  def ticket
    @ticket ||= current_user.tickets.find(params[:ticket_id])
  end

  def close?
    params[:commit] == "Close Ticket"
  end

  def message_params
    params.fetch(:support_ticket_message, {}).permit(secured_params.guest_support_message)
  end
end
