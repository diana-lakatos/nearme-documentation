# frozen_string_literal: true
require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @user.default_profile.properties = { company_name: 'DesksNearMe', country_name: 'United States' }
    @user.save!
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  context 'actions' do
    should 'successfully sign up and track' do
      assert_difference('User.count') do
        post :create, user: user_attributes
      end
    end

    should 'show profile' do
      sign_in @user

      get :show, id: @user.slug

      assert_response 200
      assert_select '.user-profile__header h1', @user.first_name
      assert_select '.profile-content dd', 'United States'
      assert_select ".user-profile__header a[rel='modal']", 'Contact'
    end

    should 'show profile with verifications' do
      sign_in @user

      fb = FactoryGirl.create(:authentication, provider: 'facebook', total_social_connections: 10)
      ln = FactoryGirl.create(:authentication, provider: 'linkedin', total_social_connections: 0)
      tw = FactoryGirl.create(:authentication, provider: 'twitter', total_social_connections: 5)
      @user.authentications << [fb, ln, tw]

      get :show, id: @user.slug

      assert_response 200
      assert_select '#verifications dt', 'Email Address'
      assert_select '#verifications dt', 'Facebook'
      assert_select '#verifications dt', 'LinkedIn'
      assert_select '#verifications dt', 'Twitter'
    end

    should 'redirect to slug url if id given' do
      get :show, id: @user.id
      assert_response 301
      assert_redirected_to profile_path(@user.slug)
    end

    should 'not display company info on user profile when user does not have a company' do
      get :show, id: @user.slug
      assert_response 200
      assert_select '.vendor-profile .shop-info p', false
    end

    should 'show company info on user profile' do
      FactoryGirl.create(:company, creator: @user)
      get :show, id: @user.slug

      assert_response 200
      assert_select '#shop-info h2', 'Company Info'
    end

    should 'display edit actions if user is logged in' do
      FactoryGirl.create(:company, creator: @user)
      sign_in @user
      get :show, id: @user.slug

      assert_response 200
      assert_select '#vendor-profile a', 'Edit'
      assert_select '#shop-info a', 'Edit'
    end
  end

  context 'verify' do
    should 'verify user if token and id are correct' do
      get :verify, id: @user.id, token: UserVerificationForm.new(@user).email_verification_token
      @user.reload
      @controller.current_user.id == @user.id
      assert @user.verified_at
    end

    should 'redirect verified user with listing to dashboard' do
      @company = FactoryGirl.create(:company, creator: @user)
      @location = FactoryGirl.create(:location, company: @company)
      FactoryGirl.create(:transactable, location: @location)
      get :verify, id: @user.id, token: UserVerificationForm.new(@user).email_verification_token
      assert_redirected_to dashboard_path
    end

    should 'redirect verified user without listing to settings' do
      get :verify, id: @user.id, token: UserVerificationForm.new(@user).email_verification_token
      assert_redirected_to edit_user_registration_path
    end

    should 'handle situation when user is verified' do
      @user.verified_at = Time.zone.now
      @user.save!
      get :verify, id: @user.id, token: UserVerificationForm.new(@user).email_verification_token
      @user.reload
      assert_equal @user.id,  @controller.current_user&.id
      assert @user.verified_at
    end

    should 'not verify user if id is incorrect' do
      assert_raise ActiveRecord::RecordNotFound do
        get :verify, id: (@user.id + 1), token: UserVerificationForm.new(@user).email_verification_token
      end
    end

    should 'not verify user if token is incorrect' do
      get :verify, id: @user.id, token: UserVerificationForm.new(@user).email_verification_token + 'incorrect'
      @user.reload
      assert_nil @controller.current_user
      assert !@user.verified_at
      assert_redirected_to root_path
    end
  end

  context 'referer and source=&campaign=' do
    setup do
      ApplicationController.class_eval do
        def first_time_visited?
          @first_time_visited = cookies.count.zero?
        end
      end
    end

    context 'on first visit' do
      should 'be stored in both cookie and db' do
        @request.env['HTTP_REFERER'] = 'https://example.com/'
        get :new, source: 'xxx', campaign: 'yyy'
        assert_equal 'xxx', cookies.signed[:source]
        assert_equal 'yyy', cookies.signed[:campaign]
        assert_equal 'https://example.com/', session[:referer]

        post :create, user: user_attributes
        user = User.find_by(email: 'user@example.com')
        assert_equal 'xxx', user.source
        assert_equal 'yyy', user.campaign
        assert_equal 'https://example.com/', user.referer
      end
    end

    context 'on repeated visits' do
      should 'be stored only on first visit' do
        @request.env['HTTP_REFERER'] = 'https://example.com/'
        get :new
        assert_nil cookies.signed[:source]
        assert_nil cookies.signed[:campaign]
        assert_equal 'https://example.com/', session[:referer]

        @request.env['HTTP_REFERER'] = 'http://homepage.com/'
        get :new, source: 'xxx', campaign: 'yyy'
        assert_equal 'xxx', cookies.signed[:source]
        assert_equal 'yyy', cookies.signed[:campaign]
        assert_equal 'http://homepage.com/', session[:referer]

        post :create, user: user_attributes
        user = User.find_by(email: 'user@example.com')
        assert_equal 'xxx', user.source
        assert_equal 'yyy', user.campaign
        assert_equal 'http://homepage.com/', user.referer
      end
    end

    context 'avatar' do
      should 'store transformation data and rotate' do
        sign_in @user
        stub_image_url('http://www.example.com/image.jpg')
        post :update_avatar, format: :js, crop: { w: 1, h: 2, x: 10, y: 20 }, rotate: 90
        @user = assigns(:user)
        assert_not_nil @user.avatar_transformation_data
        assert_equal({ 'w' => 1, 'h' => 2, 'x' => 10, 'y' => 20 }, @user.avatar_transformation_data[:crop])
        assert_equal 90, @user.avatar_transformation_data[:rotate]
      end

      should 'show error message when transformation fails' do
        sign_in @user
        stub_image_url('http://www.example.com/image.jpg')
        put :update_avatar, format: :js, crop: { w: -1000, h: 2.0, x: 10, y: 20 }, rotate: 90
        response.body.include?('Unable to save image')
      end

      should 'delete everything related to avatar when destroying avatar' do
        stub_image_url('http://www.example.com/image1.jpg')
        sign_in @user
        @user.avatar_transformation_data = { crop: { w: 1 } }
        @user.avatar_versions_generated_at = Time.zone.now
        @user.remote_avatar_url = 'http://www.example.com/image1.jpg'
        @user.save!
        delete :destroy_avatar
        @user = assigns(:user)
        assert @user.avatar_transformation_data.empty?
        assert_nil @user.avatar_versions_generated_at
        assert !@user.avatar.file.present?
      end
    end
  end

  context 'versions' do
    should 'track version change on create' do
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "User", "create").count') do
        with_versioning do
          post :create, user: user_attributes
        end
      end
    end
  end

  context 'scopes current partner' do
    setup do
      @instance = FactoryGirl.create(:instance)
      @domain = FactoryGirl.create(:domain)
      @partner = FactoryGirl.create(:partner)
    end

    should 'match partner_id and instance_id' do
      PlatformContext.any_instance.stubs(:partner).returns(@partner)
      PlatformContext.any_instance.stubs(:domain).returns(@domain)
      PlatformContext.any_instance.stubs(:instance).returns(@instance)
      Instance.any_instance.stubs(:default_profile_type).returns(FactoryGirl.create(:instance_profile_type))
      User.any_instance.stubs(:custom_validators).returns([])
      post :create, user: user_attributes
      user = User.find_by(email: 'user@example.com')
      assert_equal @partner.id, user.partner_id
      assert_equal @domain.id, user.domain_id
      assert_equal @instance.id, user.instance_id
    end
  end

  context 'sms notifications' do
    setup do
      @user.sms_notifications_enabled = false
      @user.sms_preferences = Hash[%w(user_message reservation_state_changed new_reservation).map { |sp| [sp, '1'] }]
      @user.save!
      FactoryGirl.create(:form_configuration_default_update_minimum)
    end

    should 'save sms_notifications_enabled and sms_preferences' do
      sign_in @user
      put :update_notification_preferences, user: { sms_notifications_enabled: '0', sms_preferences: { new_reservation: '1' } }
      @user.reload
      refute @user.sms_notifications_enabled
      assert_equal @user.sms_preferences, 'new_reservation' => '1'
    end
  end

  private

  def user_attributes
    { name: 'Test User', email: 'user@example.com', password: 'secret' }
  end
end
