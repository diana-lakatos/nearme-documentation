require 'test_helper'

class Authentication::TokenBasedLoginTest < ActionDispatch::IntegrationTest
  def setup
    stub_mixpanel

    @user = FactoryGirl.create(:user)
    @verifier = User::TemporaryTokenVerifier.new(@user)
  end

  context 'using a valid token' do
    should "login as the user and persist the session" do
      get url_with_login_token(@verifier.generate)
      assert_logged_in_as @user

      get "/"
      assert_logged_in_as @user
    end

    context 'with existing user' do
      setup do
        # Emulate a devise login
        @other_user = FactoryGirl.create(:user)
        post_via_redirect 'users/sign_in', 'user[email]' => @other_user.email, 'user[password]' => @other_user.password
      end

      should "logout existing user and login with token instead" do
        assert_logged_in_as @other_user
        get url_with_login_token(@verifier.generate)
        assert_not_logged_in_as @other_user
        assert_logged_in_as @user
      end
    end
  end

  context 'using an invalid token' do
    should "expired token should not log in the user" do
      get url_with_login_token(@verifier.generate(3.days.ago))
      assert_not_logged_in_as @user
    end

    should "manipulated token should not log in the user" do
      token = @verifier.generate(1.week.ago)

      # Manipulate the expiry time embedded in the token
      token = [Base64.encode64([@user.id, 3.days.from_now.to_i].join('|')).strip, token.split('--').last].join('--')

      get url_with_login_token(token)
      assert_not_logged_in_as @user
    end
  end

  private

  def assert_logged_in_as(user)
    assert response.body.include?(user.name), response.body
  end

  def assert_not_logged_in_as(user)
    assert !response.body.include?(user.name), response.body
  end

  def url_with_login_token(token)
    "/?_tx=#{token}"
  end
end
