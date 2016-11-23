# frozen_string_literal: true
class InstanceAdmin::Manage::OrdersController < InstanceAdmin::Manage::BaseController
  skip_before_action :check_if_locked
  before_action :find_order, except: :index

  def index
    @orders = order_scope.paginate(per_page: 10, page: params[:page])
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
    @order_scope ||= Order.without_state(:inactive).order('created_at DESC')
  end
end
