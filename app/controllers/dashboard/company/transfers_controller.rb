class Dashboard::Company::TransfersController < Dashboard::Company::BaseController
  def show
    # All transferred PaymentTransfers paginated
    @payment_transfers = @company.payment_transfers.order('transferred_at DESC')
    @payment_transfers = @payment_transfers.paginate(page: params[:page], per_page: 20)

    # PaymentTransfers specifically from the last 7 days
    @last_week_payment_transfers = @company
                                   .payment_transfers
                                   .transferred
                                   .last_x_days(6)
                                   .order('created_at ASC')

    @chart = ChartDecorator.decorate(@last_week_payment_transfers)
  end
end
