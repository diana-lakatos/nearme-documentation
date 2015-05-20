require 'test_helper'

class InstanceAdmin::Manage::ServiceTypes::CategoriesControllerTest < ActionController::TestCase

  def setup_categorable
    @categorable = FactoryGirl.create(:transactable_type_csv_template)
    @controller_scope = 'manage'
  end

  # NOTE - THE PART BELOW IS SHARED WITH InstanceAdmin::Manage::ProductTypes::CategoriesControllerTest #
  # Please change both files if needed!

  setup do
    PlatformContext.current = PlatformContext.new(Instance.first)

    setup_categorable

    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
    stub_mixpanel
  end

  should '#index' do
    @category = FactoryGirl.create(:category, categorable: @categorable)
    get :index, @categorable.class.to_s.foreign_key => @categorable.id
    assert_response :success
    assert_equal [@category], assigns(:categories)
    assert_equal assigns(:category).attributes, Category.new(categorable: @categorable).attributes
  end

  context 'create' do
    should 'create new category' do
      assert_difference 'Category.count' do
        post :create, @categorable.class.to_s.foreign_key => @categorable.id, category: { name: 'Desks' }
      end
      category = assigns(:category)
      assert_equal 'Desks', category.name
      assert_equal @categorable.id, category.categorable_id
      assert_redirected_to assigns(:redirect_path)
    end

    should 'render category if validation errors' do
      assert_no_difference 'Category.count' do
        post :create, @categorable.class.to_s.foreign_key => @categorable.id, category: { name: nil }
      end
      assert_response :success
      assert_equal nil, assigns(:category).name
    end
  end

  context 'existing category' do
    setup do
      @category = FactoryGirl.create(:category, categorable: @categorable)
    end

    should 'edit' do
      get :edit, @categorable.class.to_s.foreign_key => @categorable.id, id: @category.id
      assert_response :success
    end

    should 'update' do
      assert_no_difference 'Category.count' do
        put :update, @categorable.class.to_s.foreign_key => @categorable.id, id: @category.id, category: { name: 'Desks' }
      end
      category = assigns(:category)
      category.reload
      assert_equal 'Desks', category.name
      assert_equal @categorable.id, category.categorable_id
      assert_redirected_to assigns(:redirect_path)
    end

    should 'destroy' do
      assert_difference 'Category.count', -1 do
        delete :destroy, @categorable.class.to_s.foreign_key => @categorable.id, id: @category.id
      end
      assert_redirected_to url_for(['instance_admin', @controller_scope, @categorable, 'categories'])
    end

  end
end
