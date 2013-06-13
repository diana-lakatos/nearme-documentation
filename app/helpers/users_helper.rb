module UsersHelper
  def user_is_admin?
    current_user && current_user.admin?
  end

  def user_mobile_country_code_options
    COUNTRY_CALLING_CODES.map { |c, cc| ["#{c} (+#{cc})", cc] }.sort_by(&:first)
  end
end
