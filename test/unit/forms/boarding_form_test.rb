require 'test_helper'

class BoardingFormTest < ActiveSupport::TestCase

  setup do
    @product_type = FactoryGirl.create(:product_type)
    @user = FactoryGirl.create(:user, name: "Firstname Lastname")
    @boarding_form = BoardingForm.new(@user, @product_type)
    @shipping_category = FactoryGirl.create(:shipping_category)
    @shipping_category.company_id = @boarding_form.product_form.product.company.id
    @shipping_category.user_id = @user.id
    @shipping_category.save!
    @category_ids = FactoryGirl.create_list(:category, 10).map(&:id)
  end

  context "Boarding First Product" do
    should "submit params" do
      Address.any_instance.stubs(:country).returns('PL')
      assert_equal true, @boarding_form.submit(boarding_attributes)

      @company = Company.last
      @product = @company.products.first

      assert_equal @company.name, "Test Store"
      assert_equal @company.company_address.address, "Poznań, Polska"
      assert_equal @product.category_ids.sort, @category_ids.sort
      assert_equal @product.name, "Test Product"

    end
  end

  def boarding_attributes
    {
      company_attributes: {
        name: "Test Store",
        company_address_attributes: {
          address: "Poznań, Polska",
          latitude: "52.406374",
          longitude: "16.925168100000064",
        }
      },
      product_form: {
        name: "Test Product",
        description: "Test description",
        price: "100",
        category_ids: [@category_ids.join(",")],
        quantity: "10",
        shipping_category_id: @shipping_category.id
      }
    }
  end
end
