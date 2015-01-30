class CompanyDecorator < Draper::Decorator
  delegate_all

  def any_payout_option_available?
    paypal_email.present? || mailing_address.present? || instance_clients.any?
  end

end
