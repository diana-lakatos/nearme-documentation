require 'test_helper'

class Dashboard::UserMessagesControllerTest < ActionController::TestCase
  context 'listing' do
    setup do
      @listing = FactoryGirl.create(:listing_in_san_francisco)
    end

    should 'should redirected to signin if not currently logged in' do
      get :new, listing_id: @listing.id
      assert_redirected_to new_user_session_path
    end
  end

  context 'user' do
    setup do
      @user = FactoryGirl.create(:user)
    end

    should 'should redirected to signin if not currently logged in' do
      get :new, user_id: User.first.id
      assert_redirected_to new_user_session_path
    end
  end
end
