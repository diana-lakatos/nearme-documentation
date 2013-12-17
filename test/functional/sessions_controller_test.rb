require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    stub_mixpanel
  end

  should 'successfully track in mixpanel' do
    @tracker.expects(:logged_in).with do |user, custom_options|
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

  context 'versions' do

    should 'not track new version after each login' do
      assert_no_difference('Version.where("item_type = ?", "User").count') do
        with_versioning do
          post :create, user: { email: @user.email, password: @user.password }
        end
      end
    end

    should 'not track new version after each logout' do
      sign_in @user
      assert_no_difference('Version.where("item_type = ?", "User").count') do
        with_versioning do
          delete :destroy
        end
      end
    end
  end
end

