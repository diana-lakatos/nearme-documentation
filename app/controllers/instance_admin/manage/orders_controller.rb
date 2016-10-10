class InstanceAdmin::Manage::OrdersController < InstanceAdmin::Manage::BaseController
  skip_before_filter :check_if_locked
  before_filter :find_order, except: :index

  def index
    @orders = order_scope
  end

  def show
  end

  def generate_next_period
    unless Rails.env.production?
      period = @order.generate_next_period!
      period.generate_payment!
    end
    redirect_to :back
  end

  private

  def find_order
    @order = order_scope.find(params[:id])
  end

  def order_scope
    @order_scope ||= Order.without_state(:inactive).paginate(per_page: 20, page: params[:page]).order('created_at DESC')
  end
end
