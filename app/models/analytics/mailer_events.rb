module Analytics::MailerEvents

  def track_event_within_email(user, request)
    path_spec = Rails.application.routes.router.recognize(request) { |route, _| route.name }.flatten.last.path.spec.to_s.gsub(/\([^\)]*\)/, '')
    verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
    begin
      mailer_name = verifier.verify(request.params[:email_signature])
      link_within_email_clicked(user, { url: path_spec, mailer: mailer_name })
    rescue ActiveSupport::MessageVerifier::InvalidSignature => ex
      Rails.logger.error "Wrong email tracking signature: #{ex}"
    end
  end

  def link_within_email_clicked(user, custom_options = {})
    track 'Clicked link within email', user, custom_options
  end

  def email_sent(custom_options)
    track 'Email Sent', custom_options
  end

end
