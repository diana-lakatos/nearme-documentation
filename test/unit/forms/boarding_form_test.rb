require 'test_helper'

class BoardingFormTest < ActiveSupport::TestCase

  setup do
    PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
    @user = FactoryGirl.create(:user, name: "Firstname Lastname")
    @boarding_form = BoardingForm.new(@user)
    @shipping_category = FactoryGirl.create(:shipping_category)
    @shipping_category.company_id = @boarding_form.product_form.product.company.id
    @shipping_category.save!
    10.times do
      FactoryGirl.create(:taxons)
      FactoryGirl.create(:country)
    end
    @taxon_ids = Spree::Taxon.all.map(&:id)
    @countries = [FactoryGirl.create(:country)]
  end

  context "Boarding First Product" do
    should "submit params" do
      assert_equal @boarding_form.submit(boarding_attributes), true

      @company = Company.last
      @product = @company.products.first

      assert_equal @company.name, boarding_attributes[:store_name]
      assert_equal @company.company_address.address, "Poznań, Polska"
      assert_equal @product.taxons.map(&:id).sort, @taxon_ids.sort
      assert_equal @product.name, "Test Product"

    end
  end

  def boarding_attributes
    {
      store_name: "Test Store",
      company_address_attributes: {
        address: "Poznań, Polska",
        latitude: "52.406374",
        longitude: "16.925168100000064",
      },
      product_form: {
        name: "Test Product",
        description: "Test description",
        price: "100",
        taxon_ids: @taxon_ids.join(","),
        quantity: "10",
        shipping_category_id: @shipping_category.id
      }
    }
  end
end
