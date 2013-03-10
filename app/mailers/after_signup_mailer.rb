class AfterSignupMailer < DesksNearMeMailer

  def help_offer(user_id)

    @user = User.find(user_id)
    mail to:      @user.email,
      from: "micheller@desksnear.me",
      subject: "Welcome to DesksNear.me",
      template_name: choose_template
  end

  private

  def choose_template
    @user.listings.empty? ? :help_with_listing : :further_help
  end

end
