require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  should 'successfully track in mixpanel' do
    Rails.application.config.event_tracker.any_instance.expects(:logged_in).with do |user, custom_options|
      user == @user && custom_options == { provider: 'native' }
    end
    post :create, user: { email: @user.email, password: @user.password }
  end

  should 'be automatically remembered' do
    post :create, user: { email: @user.email, password: @user.password }
    @user.reload
    assert @user.remember_token
    assert_equal Time.zone.today, @user.remember_created_at.to_date
  end

  should 'be able to log out if no password set' do
    sign_in @user
    delete :destroy
    assert_equal 'Signed out successfully.', flash[:notice]
  end

  should 'not be able to log in to banned instance' do
    @user.update_attribute(:banned_at, Time.zone.now)
    post :create, user: { email: @user.email, password: @user.password }
    assert_equal 'Your account has not been activated yet.', flash[:alert]
  end

  context 'versions' do
    should 'not track new version after each login' do
      assert_no_difference('PaperTrail::Version.where("item_type = ?", "User").count') do
        with_versioning do
          post :create, user: { email: @user.email, password: @user.password }
        end
      end
    end

    should 'not track new version after each logout' do
      sign_in @user
      assert_no_difference('PaperTrail::Version.where("item_type = ?", "User").count') do
        with_versioning do
          delete :destroy
        end
      end
    end
  end
end
