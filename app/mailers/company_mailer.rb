class CompanyMailer < InstanceMailer
  layout 'mailer'

  def notify_host_of_no_payout_option(company)
    @user = company.creator
    @company = company
    mail(to: "#{@user.name} <#{@user.email}>", subject: "Your funds transfer is ready!")
  end
end
