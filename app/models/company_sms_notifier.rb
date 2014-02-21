class CompanySmsNotifier < SmsNotifier
  def notify_host_of_no_payout_option(company)
    return unless company.creator.accepts_sms?
    @company = company
    @user = company.creator
    sms :to => @user.full_mobile_number, :fallback => { :email => company.creator.email }
  end
end

