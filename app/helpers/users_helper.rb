module UsersHelper
  def user_is_admin?
    current_user && current_user.admin?
  end

  def user_country_name_options
    Country.all.map { |c| [c.name, c.name, {:'data-calling-code' => c.calling_code}] }.sort_by(&:first)
  end
end
