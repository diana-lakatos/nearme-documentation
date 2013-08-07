require 'test_helper'

class AuthenticationsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @password = "password123"
  end


  # Social Authentication


  test "authentication can be deleted if user has password set" do
    create_signed_in_user_with_authentication
    assert_difference('@user.authentications.count', -1) do
      delete :destroy, id: @user.authentications.first.id
    end
  end

  test "authentication can be deleted if user has no  password but more than one authentications" do
    create_signed_in_user_with_authentication
    add_authentication("twitter", "abc123")
    assert_difference('@user.authentications.count', -1) do
      delete :destroy, id: @user.authentications.first.id
    end
  end

  test "authentication cannot be deleted if user has no password and one authentication" do
    create_no_password_signed_in_user_and_authentication
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
      post :create
      assert flash[:error].include?('already connected to other user')
    end

    should "successfully sign in" do
      add_authentication(@provider, @uid, @user)
      sign_in @user
      post :create
      assert flash[:success].include?('Signed in successfully')
    end

    should "successfully create new authentication" do
      sign_in @user
      post :create
      assert_equal 'Authentication successful.', flash[:success]
    end

    should "fail due to incorrect email" do
      FactoryGirl.create(:user, :email => @email)
      sign_in @user
      post :create
      assert flash[:error].include?('Your Linkedin email is already linked to an account')
    end

    should "should successfully sign up and log this fact" do
      stub_request(:get, /.*api\.mixpanel\.com.*/)
      @tracker = Analytics::EventTracker.any_instance
      @tracker.expects(:signed_up).with do |user, custom_options|
        user == assigns(:oauth).authenticated_user && custom_options == { signed_up_via: 'other', provider: @provider }
      end
      assert_difference('User.count') do
        post :create
      end
    end

    should "redirect to fill missing information if cannot create user" do
      request.env['omniauth.auth'] = { 'provider' => @provider, 'uid' => @uid, 'info' => { } }
      assert_no_difference('User.count') do
        post :create
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
