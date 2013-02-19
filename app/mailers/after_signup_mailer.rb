class AfterSignupMailer < DesksNearMeMailer

  def help_offer(user)

    @user = user
    mail to:      user.email,
         from: "michelle@desksnear.me",
         subject: "Welcome to DesksNear.me"
  end

end
