class DeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers

    def reset_password_instructions(record, opts={})
      opts[:from] = PlatformContext.current.theme.contact_email_with_fallback
      opts[:reply_to] = opts[:from]
      super
    end
end

