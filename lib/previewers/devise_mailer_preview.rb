class DeviseMailerPreview < MailView

  def reset_password_instructions
    ::DeviseMailer.reset_password_instructions(User.last)
  end

end
