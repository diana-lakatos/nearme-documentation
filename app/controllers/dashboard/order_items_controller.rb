# frozen_string_literal: true
class Dashboard::OrderItemsController < Dashboard::Company::BaseController
  before_action :find_order
  before_action :find_order_item, except: [:index, :new, :create]
  before_action :can_edit?, only: [:edit, :update]
  before_action :ensure_merchant_account_exists, except: [:index]

  def index
    @transactables = current_user.orders.where.not(confirmed_at: nil).order('created_at DESC').map(&:transactable)
    @for_transactable = @transactables.find { |t| t.id.to_s == params[:transactable_id] } if params[:transactable_id].present?
  end

  def show
  end

  def new
    @order_items = @order.recurring_booking_periods.all
    @order_item = @order.recurring_booking_periods.new
  end

  def edit
  end

  def create
    @order_item = @order.recurring_booking_periods.new(order_item_params)
    if @order_item.transactable_line_items.blank? && @order_item.additional_line_items.blank?
      @order_item.errors.add(:line_items, :blank)
    else
      @order_item.set_service_fees
      @order_item.schedule_approval!

      redirect_to(dashboard_order_order_items_path(@order, transactable_id: @order.transactable.id)) && return if @order_item.save
    end

    render :new
  end

  def update
    if @order_item.update(order_item_params)
      @order_item.recalculate_fees!
      @order_item.schedule_approval!
      @order_item.send_update_alert!

      flash[:notice] = t('flash_messages.dashboard.order_items.updated')
      redirect_to dashboard_order_order_item_path(@order, @order_item)
    else
      render :new
    end
  end

  private

  def ensure_merchant_account_exists
    return if @order.blank?
    return unless @order.reservation_type.try(:require_merchant_account?)

    unless @company.merchant_accounts.any?(&:verified?)
      flash[:notice] = t('flash_messages.dashboard.order.valid_merchant_account_required')
      redirect_to edit_dashboard_company_payouts_path
    end
  end

  def can_edit?
    if (@order_item.paid? && @order_item.approved?) || @order_item.approved?
      flash[:error] = t('flash_messages.dashboard.order_items.can_not_edit_accepted_order_item')
      redirect_to dashboard_order_order_items_path(@order, transactable_id: @order.transactable.id)
      nil
    end
  end

  def order_item_params
    params.require(:recurring_booking_period).permit(secured_params.order_item)
  end

  def find_order
    @order = current_user.orders.find(params[:order_id]) if params[:order_id]
  end

  def find_order_item
    @order_item = @order.recurring_booking_periods.find(params[:id])
  end
end
