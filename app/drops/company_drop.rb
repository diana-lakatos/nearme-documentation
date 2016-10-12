class CompanyDrop < BaseDrop
  include MoneyRails::ActionViewExtension

  attr_reader :company

  # created_payment_transfers
  #   array of payment transfer objects
  # creator
  #   creator user object
  # url
  #   url address of company
  # description
  #   company description as string
  # name
  #   company name as string
  # payments_mailing_address
  #   the payments mailing address as an Address drop
  delegate :created_payment_transfers, :creator, :url, :description, :company_address,
           :name, :payments_mailing_address, :merchant_accounts, to: :company

  def initialize(company)
    @company = company
  end

  # Url to the section for adding user's paypal account where he will get paid. Includes tracking and authentication token.
  def add_paypal_url_with_tracking_and_token
    routes.edit_dashboard_company_payouts_path(token_key => @company.creator.temporary_token, track_email_event: true)
  end

  # returns list of created payment transfer as a string (list of currency amounts)
  def payment_transfers_as_string
    created_payment_transfers.map { |payment_transfer| "#{payment_transfer.amount}#{payment_transfer.amount.currency.symbol}" }.join(', ')
  end

  # Url to the section for adding user's paypal account where he will get paid. Without tracking, includes authentication token.
  def add_paypal_path_with_token
    routes.edit_dashboard_company_payouts_path(anchor: 'company_paypal_email', token_key => @company.creator.temporary_token)
  end

  # Url to the section for adding/updating user's payout information.
  def payout_path
    routes.edit_dashboard_company_payouts_path
  end

  # returns the path to editing the company
  def edit_path
    routes.edit_dashboard_company_path(@company)
  end
end
