require 'test_helper'

class InstanceAdmin::Theme::PagesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  should 'show a listing of pages associated with current theme' do
    @page = FactoryGirl.create(:page, path: 'Page test')
    get :index
    assert_response :success
    assert_select 'td', "Page test"
  end

  context 'create' do

    should 'create a new page' do
      assert_difference 'Page.count', 1 do
        post :create, page: { path: "New Page", content: "lorem ipsum" }
      end
      assert_equal 'New Page', assigns(:page).path
    end

    should 'create a new redirect' do
      assert_difference 'Page.count', 1 do
        post :create, page: { path: "New Redirect", redirect_url: "http://test.com" }
      end
      assert_equal 'New Redirect', assigns(:page).path
      assert assigns(:page).redirect?
    end
  end

  should 'destroy page' do
    @new_page = FactoryGirl.create(:page)
    assert_difference 'Page.count', -1 do
      delete :destroy, id: @new_page.id
    end
    assert_redirected_to instance_admin_theme_pages_path
  end

end

