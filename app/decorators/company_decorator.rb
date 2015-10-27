class CompanyDecorator < Draper::Decorator
  delegate_all

  def any_payout_option_available?
    merchant_accounts.verified.any?
  end

end
