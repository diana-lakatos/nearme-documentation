class Support::TicketsController < Support::BaseController
  before_filter :authenticate_user!, only: [:index, :show]

  def new
    @ticket = Support::Ticket.new
    @ticket.messages.build
    @ticket.assign_user(current_user) if current_user
    if current_user
      @attachments = Support::TicketMessageAttachment.where(uploader_id: current_user.id, ticket_id: nil, ticket_message_id: nil).all
    end
  end

  def create
    @ticket = Support::Ticket.new(ticket_params)
    @ticket.assign_user(current_user) if current_user
    @ticket.target = PlatformContext.current.platform_context_detail
    @message = @ticket.messages.first
    if @ticket.valid?
      @ticket.save!
      SupportMailer.enqueue.request_received(@ticket, @message)
      SupportMailer.enqueue.support_received(@ticket, @message)
      flash[:success] = t('flash_messages.support.ticket.created')
      if current_user
        redirect_to support_ticket_path(@ticket)
      else
        redirect_to support_root_path
      end
    else
      render :new
    end
  end

  def index
    @tickets = current_user.tickets.paginate(page: params[:page])
  end

  def show
    @ticket = current_user.tickets.find(params[:id])
    @message = Support::TicketMessage.new(attachments: @ticket.attachments.where(ticket_message_id: nil, uploader_id: current_user.id))
  end

  private

  def ticket_params
    params.require(:support_ticket).permit(secured_params.support_ticket)
  end
end
