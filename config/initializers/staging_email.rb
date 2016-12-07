class StagingEmailInterceptor
  def self.delivering_email(mail)
    rewrite = proc do |_address|
      PlatformContext.current.instance.test_email.presence || DesksnearMe::Application.config.test_email
    end

    mail.subject  = "(#{mail.to.to_sentence}) - #{mail.subject}"
    mail.to       = mail.to.map(&rewrite)
    mail.cc       = mail.cc.map(&rewrite) if mail.cc
    mail.bcc      = mail.bcc.map(&rewrite) if mail.bcc
  end
end

if DesksnearMe::Application.config.should_rewrite_email
  ActionMailer::Base.register_interceptor(StagingEmailInterceptor)
end
