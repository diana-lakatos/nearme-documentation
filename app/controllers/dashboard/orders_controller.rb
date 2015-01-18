class Dashboard::OrdersController < Dashboard::BaseController
  skip_before_filter :redirect_if_no_company

  def index
    @orders = current_user.orders.complete.paginate(page: params[:page]).order('created_at DESC').decorate
  end

  def show
    @order = current_user.orders.find_by_number(params[:id])
  end
end
