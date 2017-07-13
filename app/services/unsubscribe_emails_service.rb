class UnsubscribeEmailsService
  def unsubscribe(token)
    email = email_by_token(token)
    return unless email

    user = User.find_by(email: email)
    user.update_column :accept_emails, false
  end

  def generate_token(email)
    verifier.generate(email)
  end

  private

  def email_by_token(token)
    verifier.verify(token)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def verifier
    ActiveSupport::MessageVerifier.new(User::TemporaryTokenVerifier.secret_token)
  end
end
