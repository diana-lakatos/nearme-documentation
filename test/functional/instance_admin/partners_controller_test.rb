require 'test_helper'

class InstanceAdmin::PartnersControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @instance = FactoryGirl.create(:instance)  
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do

    should 'show a listing of partners associated with current instance' do
      @partner = FactoryGirl.create(:partner, :instance => @instance)
      get :index
      assert_select 'a', "Super Partner"
    end
  end

  context 'create' do

    should 'create a new partner' do
      assert_difference 'Partner.count', 1 do
        post :create, "partner"=>{
                        "name"=>"New Partner",
                        "search_scope_option"=>"no_scoping"
                      }
      end
      assert_equal 'New Partner', assigns(:partner).name
    end
  end
end
