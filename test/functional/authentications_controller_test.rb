require 'test_helper'

class AuthenticationsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @password = "password123"
  end


  # Social Authentication


  test "authentication can be deleted if user has password set" do
    create_signed_in_user_with_authentication
    stub_mixpanel
    @tracker.expects(:disconnected_social_provider).once.with do |user, custom_options|
      user == @user && custom_options == { provider: @user.authentications.first.provider }
    end
    assert_difference('@user.authentications.count', -1) do
      delete :destroy, id: @user.authentications.first.id
    end
  end

  test "authentication can be deleted if user has no  password but more than one authentications" do
    create_signed_in_user_with_authentication
    add_authentication("twitter", "abc123")
    stub_mixpanel
    @tracker.expects(:disconnected_social_provider).once.with do |user, custom_options|
      user == @user && custom_options == { provider: @user.authentications.first.provider }
    end
    assert_difference('@user.authentications.count', -1) do
      delete :destroy, id: @user.authentications.first.id
    end
  end

  test "authentication cannot be deleted if user has no password and one authentication" do
    create_no_password_signed_in_user_and_authentication
    assert_log_not_triggered(:disconnected_social_provider)
    assert_no_difference('@user.authentications.count') do
      delete :destroy, id: @user.authentications.first.id
    end
  end


  context 'authentication flow' do

    setup do
      @provider = 'linkedin'
      @uid = '123456'
      @email = 'test@example.com'
      @user = FactoryGirl.create(:user)
      request.env['omniauth.auth'] = { 'provider' => @provider, 'uid' => @uid, 'info' => { 'email' => @email, 'name' => 'maciek' } }
    end

    should "redirect with message if already connected" do
      @other_user = FactoryGirl.create(:user)
      add_authentication(@provider, @uid, @other_user)
      sign_in @user
      assert_no_difference('User.count') do
        assert_no_difference('Authentication.count') do
          post :create
        end
      end
      assert flash[:error].include?('already connected to other user')
    end

    should "successfully sign in and log" do
      add_authentication(@provider, @uid, @user)
      stub_mixpanel
      @tracker.expects(:logged_in).once.with do |user, custom_options|
        user == @user && custom_options == { provider: @provider }
      end
      assert_no_difference('User.count') do
        assert_no_difference('Authentication.count') do
          post :create
        end
      end
      assert flash[:success].include?('Signed in successfully')
    end

    should "successfully create new authentication and log" do
      sign_in @user
      stub_mixpanel
      @tracker.expects(:connected_social_provider).once.with do |user, custom_options|
        user == @user && custom_options == { provider: @provider }
      end
      assert_no_difference('User.count') do
        assert_difference('Authentication.count') do
          post :create
        end
      end
      assert_equal 'Authentication successful.', flash[:success]
    end

    should "fail due to incorrect email" do
      FactoryGirl.create(:user, :email => @email)
      sign_in @user
      assert_no_difference('User.count') do
        assert_no_difference('Authentication.count') do
          post :create
        end
      end
      assert flash[:error].include?('Your Linkedin email is already linked to an account')
    end

    should "should successfully sign up and log"  do
      stub_mixpanel
      @tracker.expects(:signed_up).once.with do |user, custom_options|
        user == assigns(:oauth).authenticated_user && custom_options == { signed_up_via: 'other', provider: @provider }
      end
      @tracker.expects(:connected_social_provider).once.with do |user, custom_options|
        user == assigns(:oauth).authenticated_user && custom_options == {  provider: @provider }
      end
      assert_difference('User.count') do
        assert_difference('Authentication.count') do
          post :create
        end
      end
    end

    should "redirect to fill missing information if cannot create user" do
      request.env['omniauth.auth'] = { 'provider' => @provider, 'uid' => @uid, 'info' => { } }
      assert_no_difference('User.count') do
        assert_no_difference('Authentication.count') do
          post :create
        end
      end
      assert_redirected_to new_user_registration_url
    end

  end

  private

  def add_authentication(provider, uid, user = nil)
    user ||= @user
    auth = user.authentications.find_or_create_by_provider(provider)
    auth.uid = uid
    auth.save!
  end

  def create_no_password_signed_in_user_and_authentication
    create_signed_in_user_with_authentication(false)
  end

  def create_signed_in_user_with_authentication(with_password = true)
    @user = users(:one)
    @user.password = @password if with_password
    @user.save!
    sign_in @user
    add_authentication("facebook", "123456")
    @user.authentications.each do |auth|
      auth.user = @user
      auth.user.save!
    end
  end

end
