module AnalyticWrapper

  def should_track?
    !(should_not_track_employees? && current_user_is_desksnearme_employee?)
  end

  def current_user_is_desksnearme_employee?
    @current_user && (@current_user.email.include?('@desksnear.me') || @current_user.email.include?('@perchard.com')  || email_belongs_to_employee?(@current_user.email))
  end

  def should_not_track_employees?
    Rails.env.production?
  end

  def email_belongs_to_employee?(email)
    %w(krajek6@gmail.com krajek6@o2.pl josef.simanek@gmail.com mmitchell@uflavor.com patrikjira@gmail.com pllanoc@gmail.com piotr@gega.io).include?(email)
  end

end
