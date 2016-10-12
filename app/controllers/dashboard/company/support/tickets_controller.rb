class Dashboard::Company::Support::TicketsController < Dashboard::Company::BaseController
  before_filter :find_ticket, only: [:show, :update]

  def index
    @tickets = Support::TicketDecorator.decorate_collection(current_user.assigned_company_tickets.for_filter(filter).paginate(page: params[:page]))
    @filter = filter
    @filter_name = filter_name[@filter]
  end

  def show
    @first_message = @ticket.first_message
    @message = Support::TicketMessage.new(attachments: @ticket.attachments.where(ticket_message_id: nil, uploader_id: current_user.id))
  end

  def filter
    params[:filter].presence || 'open'
  end

  def filter_name
    {
      'open' => translated_filter_name(:open),
      'resolved' => translated_filter_name(:resolved),
      'all' => translated_filter_name(:all)
    }
  end

  private

  def find_ticket
    @ticket = current_user.assigned_company_tickets.find(params[:id]).decorate
  end

  def translated_filter_name(name)
    I18n.translate(name, scope: %w(support filter_name))
  end
end
