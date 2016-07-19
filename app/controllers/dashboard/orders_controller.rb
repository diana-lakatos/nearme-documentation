class Dashboard::OrdersController < Dashboard::BaseController
  before_filter :find_order, except: [:index]

  def index
    @rating_systems = reviews_service.get_rating_systems
    @order_search_service = OrderSearchService.new(order_scope, params)
  end

  def show
  end

  def success
    render action: :show
  end

  private

  def order_scope
    @order_scope ||= current_user.orders.active
  end

  def find_order
    @order = current_user.orders.find(params[:id]).decorate
  end

  def reviews_service
    @reviews_service ||= ReviewsService.new(current_user, params)
  end
end
