class Support::DashboardController < Support::BaseController
  def index
    @faqs = platform_context.instance.faqs.rank(:position)
    @tickets = current_user.tickets.first(2) if current_user

    respond_to do |format|
      format.html
      format.js
    end
  end
end
