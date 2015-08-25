require 'test_helper'

class InstanceAdmin::BuySell::ZonesControllerTest < ActionController::TestCase

  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_buy_sell)
    @zone = FactoryGirl.create(:zone)
  end

  context 'index' do
    should 'show a listing of zones' do
      get :index
      assert_select 'td', @zone.name
    end
  end

  context "create" do
    should 'allow create zone' do
      @country = FactoryGirl.create(:spree_country)
      assert_difference 'Spree::Zone.count', 1 do
        post :create, zone: { 
                        name: 'new name',
                        description: 'test',
                        default_tax: '1',
                        kind: 'country',
                        country_ids: [@country.id]
        }
      end
      assert_redirected_to instance_admin_buy_sell_zones_path
    end
  end

  context "edit" do
    should 'allow show edit form for related zone' do
      get :edit, id: @zone.id
      assert_response :success
    end
  end

  context 'destroy' do
    should 'destroy zone' do
      assert_difference 'Spree::Zone.count', -1 do
        delete :destroy, id: @zone.id
      end
      assert_redirected_to instance_admin_buy_sell_zones_path
    end
  end

end
