class InstanceAdmin::Manage::PaymentsController < InstanceAdmin::Manage::BaseController

  skip_before_filter :check_if_locked

  def index
    @payments = PaymentDecorator.decorate_collection(Payment.needs_payment_transfer.where(failed_at: nil).order('created_at DESC').paginate(:page => params[:page]))
  end

end

