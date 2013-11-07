module SessionsHelper

  def login(user)
    auth = user.authentications.find_or_initialize_by_provider_and_token('twitter')
    if auth.new_record?
      auth.uid = FactoryGirl.attributes_for(:authentication)[:uid]
      auth.token = FactoryGirl.attributes_for(:authentication)[:token]
    end
    auth.save!
    OmniAuth.config.add_mock(:twitter, {:uid => auth.uid, :credentials => {:token => auth.token}})
    visit "/auth/twitter"
  end

  def login_manually(email='valid@example.com', password = 'password')
    visit new_user_session_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_button "Log In"
  end

  def login_with_provider(provider)
    visit new_user_session_path
    click_link authentication_link_text_for_provider(provider)
  end

  def log_out
    visit root_path
    find('.user-dropdown').click
    click_link 'Log Out'
  end
end
World(SessionsHelper)
