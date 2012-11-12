module SessionsHelper
  def login(user)
    auth = FactoryGirl.create(:authentication, :user => user)
    OmniAuth.config.add_mock(:twitter, {:uid => auth.uid})
    visit "/auth/twitter"
  end

  def user
    return model!("user") if model("user")
    @user ||= FactoryGirl.create :user
    store_model("user", "user", @user)
    model!("user")
  end
end
World(SessionsHelper)
