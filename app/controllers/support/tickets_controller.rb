class Support::TicketsController < Support::BaseController
  before_filter :authenticate_user!, only: [:index, :show]

  def new
    @ticket = Support::Ticket.new
    @ticket.messages.build
    @ticket.assign_user(current_user) if current_user
  end

  def create
    @ticket = Support::Ticket.new(ticket_params)
    @ticket.assign_user(current_user) if current_user
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
    @message = Support::TicketMessage.new
  end

  private

  def ticket_params
    params.require(:support_ticket).permit(secured_params.support_ticket)
  end
end
