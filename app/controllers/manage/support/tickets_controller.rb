class Manage::Support::TicketsController < Manage::BaseController
  before_filter :find_ticket, only: [:show, :update]

  def index
    @tickets = current_user.assigned_transactable_tickets.for_filter(filter).paginate(page: params[:page])
    @filter = filter
    @filter_name = filter_name[@filter]
  end

  def show
    @first_message = @ticket.first_message
    @message = Support::TicketMessage.new
  end

  def filter
    params[:filter].presence || 'open'
  end

  def filter_name
    {
      "open" => translated_filter_name(:open),
      "resolved" => translated_filter_name(:resolved),
      "all" => translated_filter_name(:all)
    }
  end

  private

  def find_ticket
    @ticket = current_user.assigned_transactable_tickets.find(params[:id])
  end

  def translated_filter_name(name)
    I18n.translate(name, scope: ['support', 'filter_name'])
  end


end

