require 'test_helper'

class InstanceAdmin::BuySell::TaxonomiesControllerTest < ActionController::TestCase

  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_buy_sell)
    @taxonomy = FactoryGirl.create(:taxonomy)
  end

  context 'index' do
    should 'show a listing of taxonomies' do
      get :index
      assert_select 'td', @taxonomy.name
    end
  end

  context "create" do
    should 'allow create taxonomy' do
      assert_difference 'Spree::Taxonomy.count', 1 do
        post :create, taxonomy: { name: 'new name'}
      end
      assert_redirected_to edit_instance_admin_buy_sell_taxonomy_path(Spree::Taxonomy.last)
    end
  end

  context "edit" do
    should 'allow show edit form for related taxonomy' do
      get :edit, id: @taxonomy.id
      assert_response :success
    end
  end

  context "edit_taxon" do
    should 'allow show edit form for related taxon' do
      @taxon = FactoryGirl.create(:taxon, taxonomy: @taxonomy)
      get :edit_taxon, id: @taxonomy.id, taxon_id: @taxon.id
      assert_response :success
    end
  end

  context "update_taxon" do
    should 'allow update taxon' do
      @taxon = FactoryGirl.create(:taxon, taxonomy: @taxonomy)
      put :update_taxon, id: @taxonomy.id, taxon_id: @taxon.id, taxon: {
        "name"=>"taxon name", "in_top_nav"=>"1", "top_nav_position"=>"1"
      }
      assert_redirected_to edit_instance_admin_buy_sell_taxonomy_path(@taxonomy)
    end
  end

  context 'destroy' do
    should 'destroy taxonomy' do
      assert_difference 'Spree::Taxonomy.count', -1 do
        delete :destroy, id: @taxonomy.id
      end
      assert_redirected_to instance_admin_buy_sell_taxonomies_path
    end
  end

end
