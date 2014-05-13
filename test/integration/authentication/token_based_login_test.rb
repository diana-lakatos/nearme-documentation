require 'test_helper'

class Authentication::TokenBasedLoginTest < ActionDispatch::IntegrationTest
  def setup
    stub_mixpanel

    @user = FactoryGirl.create(:user)
    @verifier = User::TemporaryTokenVerifier.new(@user)
  end

  context 'using a valid token' do
    context "redirects" do
      should 'without token parameter' do
        get url_with_login_token(@verifier.generate)
        follow_redirect!
        assert_nil request.filtered_parameters['token']
        assert_logged_in_as @user
      end

      should 'keep another parameters' do
        get url_with_login_token(@verifier.generate) + '&my_param=test'
        follow_redirect!
        assert_equal 'test', request.filtered_parameters['my_param']
        assert_logged_in_as @user
      end

      should 'remove question mark if no parameter was set' do
        get url_with_login_token(@verifier.generate)
        assert !response.header["Location"].include?('/?')
      end
    end

    should "login as the user and persist the session" do
      get_via_redirect url_with_login_token(@verifier.generate)
      assert_logged_in_as @user

      get_via_redirect "/"
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
        get_via_redirect url_with_login_token(@verifier.generate)
        assert_not_logged_in_as @other_user
        assert_logged_in_as @user
      end
    end
  end

  context 'using an invalid token' do
    should "expired token should not log in the user" do
      get_via_redirect url_with_login_token(@verifier.generate(3.days.ago))
      assert_not_logged_in_as @user
    end

    should "manipulated token should not log in the user" do
      token = @verifier.generate(1.week.ago)

      # Manipulate the expiry time embedded in the token
      token = [Base64.encode64([@user.id, 3.days.from_now.to_i].join('|')).strip, token.split('--').last].join('--')

      get_via_redirect url_with_login_token(token)
      assert_not_logged_in_as @user
    end
  end

  context 'using legacy authentication_token' do
    should "fallback to that login method" do
      get_via_redirect url_with_login_token(@user.authentication_token)
      assert_logged_in_as @user
    end
  end

  context "manage/locations_controller integration" do
    setup do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:transactable_type_location)
      post_via_redirect 'users/sign_in', 'user[email]' => @user.email, 'user[password]' => @user.password
      @company = FactoryGirl.create(:company, :creator => @user)
      @location = FactoryGirl.create(:location_in_auckland, :company => @company)
      @transactable_type = FactoryGirl.create(:transactable_type, name: 'Listing')
    end

    should 'be relogged if he uses token' do
      get_via_redirect edit_manage_location_path(:id => @location.id, :token => @location.creator.authentication_token)
      assert_response :success
    end

    should 'be prompted login form if he uses wrong token' do
      get edit_manage_location_path(:id => @location.id, :token => 'this one is certainly wrong one')
      follow_redirect!
      assert_response :redirect
      assert_redirected_to new_user_session_path(:return_to => edit_manage_location_url(:id => @location.id))
    end

    should 'be redirected back after login when token is wrong' do
      get_via_redirect edit_manage_location_path(:id => @location.id, :token => 'this one is certainly wrong one')
      post 'users/sign_in', {'user[email]' => @user.email, 'user[password]' => @user.password}, session
      assert_redirected_to edit_manage_location_path(:id => @location.id)
    end
  end

  private

  def assert_logged_in_as(user)
    assert logged_in_as(user), response.body
  end

  def assert_not_logged_in_as(user)
    refute logged_in_as(user), response.body
  end

  def logged_in_as(user)
    response.body.include?(user.name)
  end

  def url_with_login_token(token)
    "/?#{TemporaryTokenAuthenticatable::PARAMETER_NAME}=#{token}"
  end
end
