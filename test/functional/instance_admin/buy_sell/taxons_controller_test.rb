require 'test_helper'

class InstanceAdmin::BuySell::TaxonsControllerTest < ActionController::TestCase

  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_buy_sell)
    @taxonomy = FactoryGirl.create(:taxonomy)
  end

  context "edit" do
    should 'allow show edit form for related taxon' do
      @taxon = FactoryGirl.create(:taxon, taxonomy: @taxonomy)
      get :edit, taxonomy_id: @taxonomy.id, id: @taxon.id
      assert_response :success
    end
  end

  context "update" do
    should 'allow update taxon' do
      @taxon = FactoryGirl.create(:taxon, taxonomy: @taxonomy)
      put :update, taxonomy_id: @taxonomy.id, id: @taxon.id, taxon: {
        "name"=>"taxon name", "in_top_nav"=>"1", "top_nav_position"=>"1"
      }
      assert_redirected_to edit_instance_admin_buy_sell_taxonomy_path(@taxonomy)
    end
  end

end
