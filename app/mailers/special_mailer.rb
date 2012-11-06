# Special mailer for special or once-off mail outs to users
class SpecialMailer < DesksNearMeMailer

  # Notify a user that OpenID login has been removed, and advise them to log in that
  # they may need to reset their password if they haven't set one on their account.
  #
  # Usage:
  #
  #   User.joins(:authentications).where(:authentications => { :provider => 'open_id' }).uniq.find_each do |user|
  #     begin
  #       SpecialMailer.openid_support_discontinued(user).deliver
  #     rescue
  #       puts "Error trying to deliver to User##{user.id}: #{$!.inspect}"
  #     end
  #   end
  def openid_support_discontinued(user)
    @user = user

    mail(
      :subject => "Important information about your account",
      :to => @user.full_email
    )
  end
end
