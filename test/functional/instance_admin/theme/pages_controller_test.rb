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
    assert_select 'td', 'Page test'
  end

  context 'create' do
    should 'create a new page' do
      assert_difference 'Page.count', 1 do
        post :create, page: { path: 'New Page', content: 'lorem ipsum' }
      end
      assert_equal 'New Page', assigns(:page).path
    end

    should 'create a new redirect' do
      assert_difference 'Page.count', 1 do
        post :create, page: { path: 'New Redirect', redirect_url: 'http://test.com' }
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

  context 'previous versions of page' do
    setup do
      with_versioning do
        @page = FactoryGirl.create(:page, path: 'Page test')
        @page.update! content: 'Lorem'
        @page.versions.update_all(whodunnit: 'me')
      end
    end

    should 'be listed' do
      get :versions, id: @page.id
      assert_response :success
      assert_select 'table tbody tr:first-child td:first-child', text: @page.versions.reorder(created_at: :desc).first.id.to_s
    end

    should 'be viewable' do
      get :show_version, id: @page.id, version_id: @page.versions.last.id
      assert_response :success
      assert_not_equal @page.content, @page.versions.last.reify.content
      assert_select 'textarea', @page.versions.last.reify.content
    end

    should 'be rollbackable' do
      last_version_id = @page.versions.last.id
      get :rollback, id: @page.id, version_id: last_version_id
      assert_redirected_to instance_admin_theme_pages_path
      assert_equal 'Page has been successfully restored to previous version', flash[:notice]
      version = @page.versions.find last_version_id
      assert_equal @page.reload.content, version.reify.content
    end
  end
end
