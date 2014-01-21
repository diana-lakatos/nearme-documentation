class CompanyMailerPreview < MailView

  def notify_host_of_no_payout_option
    @company = PaymentTransfer.last.company
    @company.created_payment_transfers = @company.payment_transfers
    ::CompanyMailer.notify_host_of_no_payout_option(@company)
  end

end
