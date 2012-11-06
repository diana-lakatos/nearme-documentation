# Special mailer for special or once-off mail outs to users
class SpecialMailer < DesksNearMeMailer

  # Notify a user that OpenID login has been removed, and advise them to log in that
  # they may need to reset their password if they haven't set one on their account.
  def openid_support_discontinued(user)
    @user = user

    mail(
      :subject => "Important information about your account",
      :to => @user.full_email
    )
  end
end
