module SessionsHelper
  def login(user)
    auth = FactoryGirl.create(:authentication, :user => user)
    OmniAuth.config.add_mock(:twitter, {:uid => auth.uid})
    visit "/auth/twitter"
  end
end
World(SessionsHelper)
