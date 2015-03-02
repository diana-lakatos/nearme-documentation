class CompanyDrop < BaseDrop
  include MoneyRails::ActionViewExtension

  attr_reader :company

  delegate :created_payment_transfers, :creator, to: :company

  def initialize(company)
    @company = company
  end

  def add_paypal_url_with_tracking_and_token
    routes.edit_dashboard_company_payouts_path(token: @company.creator.temporary_token, track_email_event: true)
  end

  def payment_transfers_as_string
    created_payment_transfers.map { |payment_transfer| "#{payment_transfer.amount}#{payment_transfer.amount.currency.symbol}" }.join(', ')
  end

  def add_paypal_path_with_token
    routes.edit_dashboard_company_payouts_path(anchor: 'company_paypal_email', token: @company.creator.temporary_token)

  end

end
