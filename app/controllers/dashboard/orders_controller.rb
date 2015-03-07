class Dashboard::OrdersController < Dashboard::BaseController

  def index
    @rating_systems = reviews_service.get_rating_systems
    @orders = current_user.orders.complete.paginate(page: params[:page]).order('created_at DESC').decorate
  end

  def show
    @order = current_user.orders.find_by_number(params[:id])
  end

  private

  def reviews_service
    @reviews_service ||= ReviewsService.new(current_user, platform_context.instance, params)
  end
end
