require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    @tracker = Analytics::EventTracker.any_instance
  end

  context 'actions' do

    should 'successfully sign up and track' do
      @tracker.expects(:signed_up).with do |user, custom_options|
        user == assigns(:user) && custom_options == { signed_up_via: 'other', provider: 'native' }
      end
      assert_difference('User.count') do
        post :create, user: user_attributes
      end
    end

    should 'successfully update' do
      sign_in @user
      @industry = FactoryGirl.create(:industry)
      @industry2 = FactoryGirl.create(:industry)
      @tracker.expects(:updated_profile).once
      put :update, :id => @user, user: { :industry_ids => [@industry.id, @industry2.id] }
    end
  end

  context "verify" do

    should "verify user if token and id are correct" do
      get :verify, :id => @user.id, :token => @user.email_verification_token
      @user.reload
      @controller.current_user.id == @user.id
      assert @user.verified
    end

    context 'with Timecop' do

      teardown do
        Timecop.return
      end

      should "mark user as not synchronized after verification" do
        @user.mailchimp_synchronized!
        Timecop.travel(Time.zone.now+10.seconds)
        get :verify, :id => @user.id, :token => @user.email_verification_token
        @user.reload
        assert !@user.mailchimp_synchronized?
      end

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
      assert_raise ActiveRecord::RecordNotFound do
        get :verify, :id => (@user.id+1), :token => @user.email_verification_token
      end
    end

    should "not verify user if token is incorrect" do
      get :verify, :id => @user.id, :token => @user.email_verification_token+"incorrect"
      @user.reload
      assert_nil @controller.current_user
      assert !@user.verified
      assert_redirected_to root_path
    end

  end

  context 'referer' do

    should 'be stored in cookie and users column, if source and campaign params provided' do
      get :new, source: 'xxx', campaign: 'yyy'
      assert_equal '(source=xxx&campaign=yyy)', cookies.signed[:referer]

      post :create, user: user_attributes
      user = User.find_by_email('user@example.com')
      assert_equal '(source=xxx&campaign=yyy)', user.referer
    end

    should 'be stored in cookie and users column, if requests referer exists' do
      @request.env['HTTP_REFERER'] = 'http://example.com/'
      get :new
      assert_equal 'http://example.com/', cookies.signed[:referer]

      post :create, user: user_attributes
      user = User.find_by_email('user@example.com')
      assert_equal 'http://example.com/', user.referer
    end

  end

  private
  def user_attributes
    { name: 'Test User', email: 'user@example.com', password: 'secret' }
  end
end
