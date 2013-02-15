module UserHelper

  def try_to_sign_up_with_provider(provider)
    visit new_user_registration_path
    click_link authentication_link_text_for_provider(provider)
  end

  def sign_up_with_provider(provider, email = nil)
    email ||= "#{provider.downcase}@example.com"
    try_to_sign_up_with_provider(provider)
    fill_in 'user_email', with: "#{email}"
    click_button "Sign up"
  end

  def toggle_connection_with(provider)
    visit edit_user_registration_path
    find(:css, ".provider_#{provider.downcase}").click
  end

  def try_to_sign_up_manually(options = {})
    options = options.reverse_merge(default_options)

    visit new_user_registration_path
    fill_in 'user_name', with: options[:name]
    fill_in 'user_email', with: options[:email]
    fill_in 'user_password', with: options[:password]
    fill_in 'user_password_confirmation', with: options[:password]
  end

  def update_current_user_information(options = {})
    visit edit_user_registration_path
    fill_in 'user_name', with: options[:name] if options[:name]
    fill_in 'user_email', with: options[:email] if options[:email]
    fill_in 'user_password', with: options[:password] if options[:password]
    fill_in 'user_password_confirmation', with: options[:password] if options[:password]
    click_button "Save Changes"
  end

  def sign_up_manually(options = {})
    options = options.reverse_merge(default_options)
    try_to_sign_up_manually(options)
    click_button "Sign up"
  end

  def pre_existing_user(options = {})
    options = options.reverse_merge(default_options)
    sign_up_manually(options)
    log_out
  end


  def user
    return model!("user") if model("user")
    @user ||= FactoryGirl.create :user
    store_model("user", "user", @user)
    model!("user")
  end

private
  def default_options
    {:email => "valid@example.com", :password => 'password', :name => 'Name'}
  end


end

World(UserHelper)
