class Dashboard::OrdersController < Dashboard::BaseController
  before_filter :find_order, except: [:index]

  def index
    @rating_systems = reviews_service.get_rating_systems
    @orders = current_user.orders.complete.paginate(page: params[:page]).order('created_at DESC').decorate
  end

  def show
  end

  def success
    render action: :show
  end

  private

  def find_order
    @order = current_user.orders.find_by_number(params[:id])
  end

  def reviews_service
    @reviews_service ||= ReviewsService.new(current_user, params)
  end
end
