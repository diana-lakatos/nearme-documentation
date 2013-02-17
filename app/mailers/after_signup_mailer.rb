class AfterSignupMailer < DesksNearMeMailer

  def help_offer(user)

    @user = user
    define_content
    mail to:      user.email,
      from: "michelle@desksnear.me",
      subject: "Welcome to DesksNear.me"
  end


  private

  def define_content

    if @user.listings.count > 0
      @content = "I notice you added a new listing, and wanted to reach out and see if you need any further help!"
    else
      @content = "I wanted to reach out and see if you need any help listing or booking a space." 
    end
  end

end
