module UserHelper

  def try_to_sign_up_with_provider(provider)
    visit new_user_registration_path
    click_link provider.downcase
  end

  def sign_in_with_provider(provider)
    try_to_sign_up_with_provider(provider)
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
    visit new_user_registration_path
    fill_in_user_sign_up_details(options)
  end
  
  def fill_in_user_sign_up_details(options = {})
    options = options.reverse_merge(default_options)
    fill_in 'user_name', with: options[:name]
    fill_in 'user_email', with: options[:email]
    fill_in 'user_password', with: options[:password]
  end

  def update_current_user_information(options = {})
    visit edit_user_registration_path
    select options[:country_name], :from => 'user_country_name' if options[:country_name]
    fill_in 'user_name', with: options[:name] if options[:name]
    fill_in 'user_email', with: options[:email] if options[:email]
    fill_in 'user_password', with: options[:password] if options[:password]
    click_button "Save"
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
