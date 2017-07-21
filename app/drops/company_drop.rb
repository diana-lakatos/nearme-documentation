# frozen_string_literal: true
class CompanyDrop < BaseDrop
  include MoneyRails::ActionViewExtension

  # @return [CompanyDrop]
  attr_reader :company

  # @!method locations
  #   @return [Array<Location>] array of company's locations
  # @!method id
  #   @return [Integer] id of object
  # @!method created_payment_transfers
  #   @return [Array<PaymentTransfer>] array of payment transfer objects
  # @!method creator
  #   @return [UserDrop] creator user object
  # @!method url
  #   @return [String] url address of company
  # @!method description
  #   @return [String] company description as string
  # @!method name
  #   @return [String] company name as string
  # @!method payments_mailing_address
  #   @return [AddressDrop] the payments mailing address as an AddressDrop object
  # @!method company_address
  #   @return [AddressDrop] the address of the company as an AddressDrop object
  # @!method merchant_accounts
  #   @return [Array<MerchantAccountDrop>] array of merchant accounts configured for the company
  delegate :created_payment_transfers, :creator, :url, :description, :company_address,
           :name, :payments_mailing_address, :merchant_accounts, :locations, :id, to: :company

  def initialize(company)
    @company = company
  end

  # @return [String] Url to the section for adding user's paypal account where he will get paid. Includes tracking and authentication token.
  # @todo -- deprecate - url filter
  def add_paypal_url_with_tracking_and_token
    routes.edit_dashboard_company_payouts_path(token_key => @company.creator.temporary_token)
  end

  # @return [String] list of created payment transfer as a string (list of currency amounts)
  # @todo -- investigate if this is the right place to do such things and if this should be needed
  # especially with formatting, since some currencies are before the amount and some are after
  def payment_transfers_as_string
    created_payment_transfers.map { |payment_transfer| "#{payment_transfer.amount}#{payment_transfer.amount.currency.symbol}" }.join(', ')
  end

  # @return [String] Url to the section for adding user's paypal account where he will get paid. Without tracking, includes authentication token.
  # @todo -- deprecate - url filter
  def add_paypal_path_with_token
    routes.edit_dashboard_company_payouts_path(anchor: 'company_paypal_email', token_key => @company.creator.temporary_token)
  end

  # @return [String] Url to the section for adding/updating user's payout information.
  # @todo -- deprecate - url filter
  def payout_path
    routes.edit_dashboard_company_payouts_path
  end

  # @return [String] the path to editing the company
  # @todo -- deprecate - url filter
  def edit_path
    routes.edit_dashboard_company_path(@company)
  end
end
