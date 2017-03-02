require 'test_helper'

class InstanceAdmin::Manage::CategoriesControllerTest < ActionController::TestCase
  setup do
    @categorizable = FactoryGirl.create(:transactable_type_csv_template)
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  should '#index' do
    @category = FactoryGirl.create(:category, transactable_type_ids: [@categorizable.id])
    get :index
    assert_response :success
    assert_equal [@category], assigns(:categories)
  end

  context 'create' do
    should 'create new category' do
      assert_difference 'Category.count' do
        post :create, category: { name: 'Desks', transactable_type_ids: [@categorizable.id] }
      end
      category = assigns(:category)
      assert_equal 'Desks', category.name
      assert_equal [category.id], @categorizable.categories.pluck(:id)
      assert_redirected_to edit_instance_admin_manage_category_path(category)
    end

    should 'render category if validation errors' do
      assert_no_difference 'Category.count' do
        post :create, category: { name: nil }
      end
      assert_response :success
      assert_nil assigns(:category).name
    end
  end

  context 'existing category' do
    setup do
      @category = FactoryGirl.create(:category, transactable_type_ids: [@categorizable.id])
    end

    should 'edit' do
      get :edit, id: @category.id
      assert_response :success
    end

    should 'update' do
      assert_no_difference 'Category.count' do
        put :update, id: @category.id, category: { name: 'Desks' }
      end
      category = assigns(:category)
      category.reload
      assert_equal 'Desks', category.name
      assert_redirected_to edit_instance_admin_manage_category_path(category)
    end

    should 'destroy' do
      assert_difference 'Category.count', -1 do
        delete :destroy, id: @category.id
      end
      assert_redirected_to instance_admin_manage_categories_path
    end
  end
end
