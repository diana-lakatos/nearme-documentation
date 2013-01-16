module UserHelper

  def try_to_sign_up_with_provider(provider)
    visit new_user_registration_path
    click_link provider
  end

  def sign_up_with_provider(provider, email = nil)
    email ||= "#{provider.downcase}@example.com"
    try_to_sign_up_with_provider(provider)
    fill_in 'user_email', with: "#{email}"
    click_button "Sign up"
  end

  def toggle_connection_with(provider)
    visit edit_user_registration_path
    within "#provider_#{provider.downcase}" do
      click_link "#{provider}"
    end
  end

  def try_to_sign_up_manually(email = "valid@example.com", password = 'password', name = 'Name')
    visit new_user_registration_path
    fill_in 'user_name', with: name
    fill_in 'user_email', with: "#{email}"
    fill_in 'user_password', with: "#{password}"
    fill_in 'user_password_confirmation', with: "#{password}"
  end

  def sign_up_manually(email = "valid@example.com", password = 'password', name = 'Name', debug = false)
    try_to_sign_up_manually(email, password, name)
    click_button "Sign up"
  end

  def pre_existing_user(email = "valid@example.com", password = 'password', name = 'Name')
    sign_up_manually(email, password, name)
    log_out
  end


end

World(UserHelper)
