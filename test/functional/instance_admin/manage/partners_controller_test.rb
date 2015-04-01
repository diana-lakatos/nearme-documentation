require 'test_helper'

class InstanceAdmin::Manage::PartnersControllerTest < ActionController::TestCase

  setup do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do

    should 'show a listing of partners associated with current instance' do
      @partner = FactoryGirl.create(:partner, :instance => @instance)
      get :index
      assert_select 'tr', "Super Partner"
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

  context 'theme' do
    setup do
      CompileThemeJob.stubs(:perform)
    end

    %i(create update).each do |action|
      context action do
        should 'not create a theme unless add_theme param passed' do
          assert_no_difference 'Theme.count' do
            params = {"partner"=> {"name" => "New Partner", "search_scope_option" => "no_scoping"}}
            params.merge!(id: create(:partner).id) if action == :update
            post action, params
          end
          assert_redirected_to(action == :create ? {action: :index} : {action: :edit, id: assigns(:partner).id})
        end

        should 'create theme if add_theme param passed' do
          assert_difference 'Theme.count', 1 do
            params = {"partner" => {"name" => "New Partner","search_scope_option" => "no_scoping"}, "add_theme" => '1'}
            params.merge!(id: create(:partner).id) if action == :update
            post action, params
          end
          assert_redirected_to(action: :edit, id: assigns(:partner).id)
        end
      end
    end
  end
end
