class CompanySmsNotifier < SmsNotifier
  def notify_host_of_no_payout_option(company)
    return unless company.creator.accepts_sms?
    @company = company
    @user = company.creator
    @platform_context = PlatformContext.new.initialize_with_company(@company).decorate
    sms :to => @user.full_mobile_number
  end
end

