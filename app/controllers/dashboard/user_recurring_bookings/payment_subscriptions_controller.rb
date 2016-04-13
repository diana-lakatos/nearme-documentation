class Dashboard::UserRecurringBookings::PaymentSubscriptionsController <  Dashboard::BaseController
  before_filter :find_recurring_booking
  before_filter :find_payment_subscription
  before_filter :find_unpaid_recurring_booking_periods
  before_filter :check_if_updateable, only: [:edit, :update]

  def edit
  end

  def update
    if @payment_subscription.update_attributes(payment_subscription_params)
      if @unpaid_recurring_booking_periods.all? { |rbp| rbp.update_payment.paid? }
        flash[:success] = t('flash_messages.payments.updated')
        @recurring_booking.reconfirm!
      else
        flash[:error] = t('flash_messages.payments.authorization_failed_anyway')
      end
      redirect_to dashboard_user_recurring_bookings_path
      render_redirect_url_as_json
    else
      render :edit
    end
  end

  private

  def find_recurring_booking
    @recurring_booking = current_user.recurring_bookings.find(params[:user_recurring_booking_id])
  end

  def find_payment_subscription
    @payment_subscription = @recurring_booking.payment_subscription
  end

  def check_if_updateable
    unless @recurring_booking.overdued? && @unpaid_recurring_booking_periods.exists?
      flash[:error] = t('flash_messages.payments.cannot_edit')
      redirect_to dashboard_user_recurring_bookings_path
    end
  end

  def payment_subscription_params
    params.require(:payment_subscription).permit(secured_params.payment_subscription)
  end

  def find_unpaid_recurring_booking_periods
    @unpaid_recurring_booking_periods = @payment_subscription.subscriber.recurring_booking_periods
  end

end

