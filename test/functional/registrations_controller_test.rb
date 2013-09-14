require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    stub_mixpanel
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
      @tracker.expects(:updated_profile_information).once
      put :update, :id => @user, user: { :industry_ids => [@industry.id, @industry2.id] }
    end
  end

  context "verify" do

    should "verify user if token and id are correct" do
      get :verify, :id => @user.id, :token => @user.email_verification_token
      @user.reload
      @controller.current_user.id == @user.id
      assert @user.verified_at
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
      assert_redirected_to edit_user_registration_path
    end

    should "handle situation when user is verified" do
      @user.verified_at = Time.zone.now
      @user.save!
      get :verify, :id => @user.id, :token => @user.email_verification_token
      @user.reload
      assert_nil @controller.current_user
      assert @user.verified_at
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
      assert !@user.verified_at
      assert_redirected_to root_path
    end

  end

  context 'referer and source=&campaign=' do

    setup do
      ApplicationController.class_eval do
        def first_time_visited?; @first_time_visited = cookies.count.zero?; end
      end
    end

    context 'on first visit' do
      should 'be stored in both cookie and db' do
        @request.env['HTTP_REFERER'] = 'http://example.com/'
        get :new, source: 'xxx', campaign: 'yyy'
        assert_equal 'xxx', cookies.signed[:source]
        assert_equal 'yyy', cookies.signed[:campaign]
        assert_equal 'http://example.com/', cookies.signed[:referer]

        post :create, user: user_attributes
        user = User.find_by_email('user@example.com')
        assert_equal 'xxx', user.source
        assert_equal 'yyy', user.campaign
        assert_equal 'http://example.com/', user.referer
      end
    end

    context 'on repeated visits' do
      should 'be stored only on first visit' do
        @request.env['HTTP_REFERER'] = 'http://example.com/'
        get :new
        assert_nil cookies.signed[:source]
        assert_nil cookies.signed[:campaign]
        assert_equal 'http://example.com/', cookies.signed[:referer]

        @request.env['HTTP_REFERER'] = 'http://homepage.com/'
        get :new, source: 'xxx', campaign: 'yyy'
        assert_nil cookies.signed[:source]
        assert_nil cookies.signed[:campaign]
        assert_equal 'http://example.com/', cookies.signed[:referer]

        post :create, user: user_attributes
        user = User.find_by_email('user@example.com')
        assert_nil user.source
        assert_nil user.campaign
        assert_equal 'http://example.com/', user.referer
      end
    end

    context 'avatar' do 

      should 'store transformation data and rotate' do
        sign_in @user
        stub_image_url("http://www.example.com/image.jpg")
        post :update_avatar, { :crop => { :w => 1, :h => 2, :x => 10, :y => 20 }, :rotate => 90 } 
        @user = assigns(:user)
        assert_not_nil @user.avatar_transformation_data
        assert_equal ({ 'w' => '1', 'h' => '2', 'x' => '10', 'y' => '20' }), @user.avatar_transformation_data[:crop]
        assert_equal "90", @user.avatar_transformation_data[:rotate]
      end

      should 'delete everything related to avatar when destroying avatar' do
        sign_in @user
        @user.avatar_transformation_data = { :crop => { :w => 1 } }
        @user.avatar_versions_generated_at = Time.zone.now
        @user.avatar_original_url = "example.jpg"
        @user.save!
        delete :destroy_avatar, { :crop => { :w => 1, :h => 2, :x => 10, :y => 20 }, :rotate => 90 } 
        @user = assigns(:user)
        assert_nil @user.avatar_transformation_data
        assert_nil @user.avatar_versions_generated_at
        assert_nil @user.avatar_original_url
        assert !@user.avatar.any_url_exists?

      end
    end

  end

  private
  def user_attributes
    { name: 'Test User', email: 'user@example.com', password: 'secret' }
  end
end
