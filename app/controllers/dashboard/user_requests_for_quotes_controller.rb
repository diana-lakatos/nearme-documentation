class Dashboard::UserRequestsForQuotesController < Dashboard::BaseController
  def index
    @filter = filter
    @filter_name = filter_name[@filter]
    @tickets = Support::TicketDecorator.decorate_collection(current_user.requests_for_quotes.for_filter(filter).paginate(page: params[:page]))
  end

  def show
    @ticket = current_user.tickets.find(params[:id]).decorate
    @message = Support::TicketMessage.new(attachments: @ticket.attachments.where(ticket_message_id: nil, uploader_id: current_user.id))
  end

  private

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

  def translated_filter_name(name)
    I18n.translate(name, scope: %w(support filter_name))
  end
end
