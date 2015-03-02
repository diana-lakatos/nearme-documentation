require 'test_helper'

class Dashboard::Company::ProductsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    @product_type = FactoryGirl.create(:product_type)
    @product = FactoryGirl.create(:product, product_type: @product_type)
    @product.company = @company
    @product.save
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
      shipping_methods_attributes: {
        "0" => {
          name: "Test",
          removed: "0",
          processing_time: "1 day",
          calculator_attributes: {
            preferred_amount: "10.0"
          },
          zones_attributes: {
            "0" => {
              name: "Default - b38723c89b795233677b2795d77557af",
              kind: "country",
              country_ids: @countries.map(&:id).join(",")
            }
          }
        }
      }
    }
  end
end
