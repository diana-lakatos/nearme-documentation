module SessionsHelper

  def login(user)
    auth = FactoryGirl.create(:authentication, :user => user)
    OmniAuth.config.add_mock(:twitter, {:uid => auth.uid})
    visit "/auth/twitter"
  end

  def login_manually(email='valid@example.com', password = 'password')
    visit new_user_session_path
    fill_in 'user_email', with: "#{email}"
    fill_in 'user_password', with: "#{password}"
    click_button "Log In"
  end

  def login_with_provider(provider)
    visit new_user_session_path
    click_link provider
  end

  def log_out
    visit root_path
    click_link 'Logout'
  end

  begin
    def user
      return model!("user") if model("user")
      @user ||= FactoryGirl.create :user
      store_model("user", "user", @user)
      model!("user")
    end
  end
end
World(SessionsHelper)
