class Support::RequestsForQuotesController < Support::BaseController
  before_filter :authenticate_user!, only: [:index]

  def index
    @tickets = current_user.requests_for_quotes.for_filter(filter).paginate(page: params[:page])
    @filter = filter
    @filter_name = filter_name[@filter]
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

  def translated_filter_name(name)
    I18n.translate(name, scope: ['support', 'filter_name'])
  end


end
