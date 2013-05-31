require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    @tracker = Analytics::EventTracker.any_instance
  end

  should 'successfully sign up and track' do
    @tracker.expects(:signed_up).with do |user, custom_options|
      user == assigns(:user) && custom_options == { signed_up_via: 'other', provider: 'native' }
    end
    assert_difference('User.count') do
      post :create, user: { name: 'Test User', email: 'user@example.com', password: 'secret' }
    end
  end

  context "verify" do

    should "verify user if token and id are correct" do
      get :verify, :id => @user.id, :token => @user.email_verification_token
      @user.reload
      @controller.current_user.id == @user.id
      assert @user.verified
    end

    should "mark user as not synchronized after verification" do
      @user.mailchimp_synchronized!
      Timecop.travel(Time.now.utc+10.seconds)
      get :verify, :id => @user.id, :token => @user.email_verification_token
      @user.reload
      assert !@user.mailchimp_synchronized?
    end

    should "redirect verified user with listing to dashboard" do
      @company = FactoryGirl.create(:company, :creator => @user)
      @location = FactoryGirl.create(:location, :company => @company)
      FactoryGirl.create(:listing, :location => @location)
      get :verify, :id => @user.id, :token => @user.email_verification_token
      assert_redirected_to manage_locations_path
    end

    should "redirect verified user without listing to settings" do
      get :verify, :id => @user.id, :token => @user.email_verification_token
      assert_redirected_to edit_user_registration_path(@user)
    end

    should "handle situation when user is verified" do
      @user.verified = true
      @user.save!
      get :verify, :id => @user.id, :token => @user.email_verification_token
      @user.reload
      assert_nil @controller.current_user
      assert @user.verified
    end

    should "not verify user if id is incorrect" do
      get :verify, :id => (@user.id+1), :token => @user.email_verification_token
      @user.reload
      assert_nil @controller.current_user
      assert !@user.verified
    end

    should "not verify user if token is incorrect" do
      get :verify, :id => @user.id, :token => @user.email_verification_token+"incorrect"
      @user.reload
      assert_nil @controller.current_user
      assert !@user.verified
      assert_redirected_to root_path
    end

  end
end
