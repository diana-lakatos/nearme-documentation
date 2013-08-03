module UsersHelper
  def user_is_admin?
    current_user && current_user.admin?
  end

  def user_country_name_options
    Country.all.map { |c| [c.name, c.name, {:'data-calling-code' => c.calling_code}] }.sort_by(&:first)
  end

  def admin_as_user?
    session[:admin_as_user].present? && current_user
  end

  def original_admin_user
    @original_admin_user ||= User.find(session[:admin_as_user][:admin_user_id])
  end
end
