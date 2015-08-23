require 'test_helper'

class InstanceAdmin::BuySell::ProductTypes::CategoriesControllerTest < ActionController::TestCase

  def setup_categorizable
    @categorizable = FactoryGirl.create(:product_type)
    @controller_scope = 'buy_sell'
  end

  # NOTE - THE PART BELOW IS SHARED WITH InstanceAdmin::Manage::ServiceTypes::CategoriesControllerTest #
  # Please change both files if needed!

  setup do
    setup_categorizable
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
    stub_mixpanel
  end

  should '#index' do
    @category = FactoryGirl.create(:category, categorizable: @categorizable)
    get :index, @categorizable.class.to_s.foreign_key => @categorizable.id
    assert_response :success
    assert_equal [@category], assigns(:categories)
    assert_equal assigns(:category).attributes, Category.new(categorizable: @categorizable).attributes
  end

  context 'create' do
    should 'create new category' do
      assert_difference 'Category.count' do
        post :create, @categorizable.class.to_s.foreign_key => @categorizable.id, category: { name: 'Desks' }
      end
      category = assigns(:category)
      assert_equal 'Desks', category.name
      assert_equal @categorizable.id, category.categorizable_id
      assert_redirected_to assigns(:redirect_path)
    end

    should 'render category if validation errors' do
      assert_no_difference 'Category.count' do
        post :create, @categorizable.class.to_s.foreign_key => @categorizable.id, category: { name: nil }
      end
      assert_response :success
      assert_equal nil, assigns(:category).name
    end
  end

  context 'existing category' do
    setup do
      @category = FactoryGirl.create(:category, categorizable: @categorizable)
    end

    should 'edit' do
      get :edit, @categorizable.class.to_s.foreign_key => @categorizable.id, id: @category.id
      assert_response :success
    end

    should 'update' do
      assert_no_difference 'Category.count' do
        put :update, @categorizable.class.to_s.foreign_key => @categorizable.id, id: @category.id, category: { name: 'Desks' }
      end
      category = assigns(:category)
      category.reload
      assert_equal 'Desks', category.name
      assert_equal @categorizable.id, category.categorizable_id
      assert_redirected_to assigns(:redirect_path)
    end

    should 'destroy' do
      assert_difference 'Category.count', -1 do
        delete :destroy, @categorizable.class.to_s.foreign_key => @categorizable.id, id: @category.id
      end
      assert_redirected_to url_for(['instance_admin', @controller_scope, @categorizable, 'categories'])
    end

  end
end
