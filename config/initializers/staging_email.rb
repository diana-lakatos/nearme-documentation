class StagingEmailInterceptor
  def self.delivering_email(mail)
    #TODO: Get rid of this once Intel is migrated to production environment from staging
    unless PlatformContext.current.try(:instance).try(:id) == 132
      rewrite = Proc.new do |address|
        DesksnearMe::Application.config.test_email
      end

      mail.subject  = "(#{mail.to.to_sentence}) - #{mail.subject}"
      mail.to       = mail.to.map(&rewrite)
      mail.cc       = mail.cc.map(&rewrite) if mail.cc
      mail.bcc      = nil
    end
  end
end

if DesksnearMe::Application.config.should_rewrite_email
  ActionMailer::Base.register_interceptor(StagingEmailInterceptor)
end
