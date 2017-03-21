# frozen_string_literal: true
class Dashboard::Company::Support::TicketMessagesController < Dashboard::Company::BaseController
  def create
    message = ::Support::TicketMessage.new(support_ticket_message_params)
    message.user = current_user
    message.ticket = ticket
    if message.save
      WorkflowStepJob.perform(WorkflowStep::RfqWorkflow::Replied, message.id, as: current_user)
      flash[:success] = if ticket.target.action_free_booking?
                          t('flash_messages.support.rfq_ticket_message.created')
                        else
                          t('flash_messages.support.offer_ticket_message.created')
                        end
    else
      flash[:error] = t('flash_messages.support.ticket_message.error') unless close?
    end

    if close?
      if ticket.resolve
        flash[:success] = if ticket.target.action_free_booking?
                            t('flash_messages.support.rfq_ticket_message.closed')
                          else
                            t('flash_messages.support.offer_ticket_message.closed')
                          end
      else
        flash[:success] = if ticket.target.action_free_booking?
                            t('flash_messages.support.rfq_ticket_message.error')
                          else
                            t('flash_messages.support.offer_ticket_message.error')
                          end
      end
    end

    redirect_to dashboard_company_support_ticket_path(ticket)
  end

  private

  def ticket
    @ticket ||= current_user.assigned_tickets.find(params[:ticket_id])
  end

  def close?
    params[:commit] == 'Send and Resolve'
  end

  def support_ticket_message_params
    params.fetch(:support_ticket_message, {}).permit(secured_params.support_message)
  end
end
