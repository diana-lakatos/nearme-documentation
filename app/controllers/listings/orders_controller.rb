class Listings::OrdersController < ApplicationController
  # if current_user is nil, most likely authenticity_token
  # was not passed :)
  before_action :authenticate_user!, unless: -> { current_instance.use_cart? }, except: :store_order
  before_action :restore_params, only: [:index]
  before_action :find_transactable
  before_action :find_or_create_order, except: :index

  def index
  end

  def create
    @order.try(:last_search_json=, cookies[:last_search])
    if @order.add_line_item!(order_params)
      if current_instance.use_cart?
        redirect_to cart_index_path
      else
        redirect_to order_checkout_path(@order)
      end
    else
      flash[:error] = @order.errors.full_messages.join(',')
      redirect_to @transactable.decorate.show_path
    end
  end

  # Store the reservation request in the session so that it can be restored when returning to the listings controller.
  def store_order
    session[:stored_order_transactable_id] = @transactable.id
    session[:stored_order_trigger] ||= {}
    session[:stored_order_trigger][@transactable.id.to_s] = params[:commit]

    # Marshals the booking request parameters into a better structured hash format for transmission and
    # future assignment to the Bookings JS controller.
    #
    # Returns a Hash of listing id's to hash of date & quantity values.
    #  { '123' => { 'date' => '2012-08-10', 'quantity => '1' }, ... }
    dates = @transactable.event_booking? ? order_params[:dates] : order_params[:dates].try(:split, ',')
    session[:stored_order_bookings] = {
      @transactable.id => order_params.merge(dates: dates)
    }

    head 200 if params[:action] == 'store_order'
  end

  protected

  def find_transactable
    @transactable = Transactable.find(params[:listing_id])
    @transactable_pricing = @transactable.action_type.pricings.find(order_params[:transactable_pricing_id])
  end

  # def currency
  #   @currency ||= Currency.find_by_iso_code(@transactable.currency)
  # end

  def find_or_create_order
    if current_instance.use_cart? && @transactable_pricing.order_class == Purchase
      @order = @transactable_pricing.order_class.cart.where(
        user: current_user,
        currency: @transactable.currency,
        reservation_type: @transactable.transactable_type.reservation_type,
        company_id: @transactable.company_id
      ).first_or_initialize(
        user: current_user
      )
    else
      @order = @transactable_pricing.order_class.new(
        currency: @transactable.currency,
        user: current_user
      )
    end
    @order.user.try(:skip_validations_for=, [:seller, :buyer, :default])
    @order
  end

  def authenticate_user!
    session[:order_params] = params[:order] if params[:order].present?
    super
  end

  def restore_params
    params[:order] = session[:order_params]
    session[:order_params] = nil
  end

  def order_params
    params.require(:order).permit(secured_params.order(@transactable.transactable_type.reservation_type))
  end
end
