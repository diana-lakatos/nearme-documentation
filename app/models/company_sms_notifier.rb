class CompanySmsNotifier < SmsNotifier
  def notify_host_of_no_payout_option(platform_context, company)
    return unless company.creator.accepts_sms?
    @company = company
    @user = company.creator
    @platform_context = platform_context.decorate
    sms :to => @user.full_mobile_number, :fallback => { :email => company.creator.email, :platform_context => @platform_context }
  end
end

