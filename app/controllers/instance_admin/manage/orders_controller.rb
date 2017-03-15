# frozen_string_literal: true
class InstanceAdmin::Manage::OrdersController < InstanceAdmin::Manage::BaseController
  skip_before_action :check_if_locked
  before_action :find_order, except: :index

  def index
    respond_to do |format|
      format.html { @orders = get_orders_from_params.paginate(per_page: reports_per_page, page: params[:page]) }
      format.csv { send_data generate_csv(OrderDecorator.decorate_collection(get_orders_from_params)) }
    end
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

  def generate_csv(orders)
    CSV.generate do |csv|
      csv << OrderDecorator.column_headings_for_report

      orders.each do |resource|
        csv << resource.column_values_for_report
      end
    end
  end

  def get_orders_from_params
    scope_search_form = InstanceAdmin::OrderSearchForm.new
    scope_search_form.validate(params)

    SearchService.new(order_scope).search(scope_search_form.to_search_params)
  end

  def find_order
    @order = order_scope.find(params[:id])
  end

  def order_scope
    @order_scope ||= Order.without_state(:inactive)
  end
end
