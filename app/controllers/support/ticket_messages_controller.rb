# frozen_string_literal: true
class Support::TicketMessagesController < Support::BaseController
  def create
    message = Support::TicketMessage.new(message_params)
    message.user = current_user
    message.ticket = ticket
    if message.valid?
      message.save!
      if ticket.target_rfq?
        WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Updated, message.id, as: current_user)
        flash[:success] = if ticket.target.action_free_booking?
                            t('flash_messages.support.rfq_ticket_message.created')
                          else
                            t('flash_messages.support.offer_ticket_message.created')
                          end
      else
        WorkflowStepJob.perform(WorkflowStep::SupportWorkflow::Updated, message.id, as: current_user)
        flash[:success] = t('flash_messages.support.ticket_message.created')
      end
    else
      unless close?
        if ticket.target_rfq?
          flash[:error] = if ticket.target.action_free_booking?
                            t('flash_messages.support.rfq_ticket_message.error')
                          else
                            t('flash_messages.support.offer_ticket_message.error')
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

    if ticket.target_rfq?
      redirect_to dashboard_user_requests_for_quote_path(ticket)
    else
      redirect_to support_ticket_path(ticket)
    end
  end

  private

  def ticket
    @ticket ||= current_user.tickets.find(params[:ticket_id])
  end

  def close?
    params[:commit] == 'Close Ticket'
  end

  def message_params
    params.fetch(:support_ticket_message, {}).permit(secured_params.guest_support_message)
  end
end
