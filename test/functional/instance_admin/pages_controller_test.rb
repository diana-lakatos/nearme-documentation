require 'test_helper'

class InstanceAdmin::PagesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @theme = FactoryGirl.create(:theme)  
    PlatformContext.any_instance.stubs(:theme).returns(@theme)
    InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do

    should 'show a listing of pages associated with current theme' do
      @page = FactoryGirl.create(:page, :path => 'Page test', :theme => @theme)
      get :index
      assert_response :success
      assert_select 'a', "Page test"
    end
  end

  context 'create' do

    should 'create a new page' do
      assert_difference 'Page.count', 1 do
        post :create, "page"=>{
                        "path"=>"New Page",
                        "content"=>"lorem ipsum"
                      }
      end
      assert_equal 'New Page', assigns(:page).path
    end
  end

  context 'destroy' do

    should 'destroy page' do
      @new_page = FactoryGirl.create(:page, :theme => @theme)
      assert_difference 'Page.count', -1 do
        delete :destroy, :id => @new_page.id
      end
      assert_redirected_to instance_admin_pages_path
    end
  end
end
