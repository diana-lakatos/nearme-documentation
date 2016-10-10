class Support::RequestsForQuotesController < Support::BaseController
  def index
    redirect_to dashboard_user_requests_for_quotes_path
  end
end
