require 'test_helper'

class Dashboard::Company::ProductsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    @product_type = FactoryGirl.create(:product_type)
    @product = FactoryGirl.create(:product, product_type: @product_type)
    @product.company = @company
    @product.user = @user
    @product.save!
    @shipping_category = FactoryGirl.create(:shipping_category)
    @shipping_category.company_id = @company.id
    @shipping_category.save!
    @shipping_method = FactoryGirl.create(:shipping_method, shipping_category_param: @shipping_category)
    10.times { FactoryGirl.create(:taxons) }
    @taxon_ids = Spree::Taxon.all.map(&:id)
    @countries = Spree::Country.last(10)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  should 'create new product' do
    assert_difference 'Spree::Product.count' do
      post :create, {
        product_type_id: @product.product_type.id,
        product_form: product_form_attributes
      }
    end
  end

  should 'edit product name' do
    put :update, {
      product_form: {name: 'Changed name'},
      id: @product.slug,
      product_type_id: @product.product_type.id
    }
    assert assigns(:product).name, @product.reload.name
  end

  should 'create mirror copies of system shipping categories' do
    initial_count = Spree::ShippingCategory.where(user_id: @user.id, is_system_profile: false).length
    get :new
    after_count = Spree::ShippingCategory.where(user_id: @user.id, is_system_profile: false).length
    assert_equal initial_count, after_count

    @shipping_category.update_attributes(is_system_profile: true, is_system_category_enabled: true)

    initial_count = Spree::ShippingCategory.where(user_id: @user.id, is_system_profile: false).length
    get :new
    after_count = Spree::ShippingCategory.where(user_id: @user.id, is_system_profile: false).length
    after_shipping_category = Spree::ShippingCategory.order('id DESC').where(user_id: @user.id, is_system_profile: false).first
    assert_equal initial_count + 1, after_count

    assert_not_equal @shipping_category.id, after_shipping_category.id
    assert_equal @shipping_category.shipping_methods.length, after_shipping_category.shipping_methods.length
    assert_equal @shipping_category.shipping_methods.first.zones.length, after_shipping_category.shipping_methods.first.zones.length
    assert_equal @shipping_category.shipping_methods.first.zones.first.members.length, after_shipping_category.shipping_methods.first.zones.first.members.length
  end

  def product_form_attributes
    {
      name: "Test Product",
      description: "Test description",
      price: "100",
      taxon_ids: @taxon_ids.join(","),
      quantity: "10",
      shipping_category_id: @shipping_category.id
    }
  end
end
