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
