require 'test_helper'

class BoardingFormTest < ActiveSupport::TestCase

  setup do
    PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
    @user = FactoryGirl.create(:user, name: "Firstname Lastname")
    @boarding_form = BoardingForm.new(@user)
    10.times { FactoryGirl.create(:taxons) }
    @taxon_ids = Spree::Taxon.all.map(&:id)
    @countries = Spree::Country.last(10)
  end

  context "Boarding First Product" do
    should "submit params" do
      assert_equal @boarding_form.submit(boarding_attributes), true

      @company = Company.last
      @product = @company.products.first
      @shipping_method = @company.shipping_methods.first

      assert_equal @company.name, boarding_attributes[:store_name]
      assert_equal @company.company_address.address, "Poznań, Polska"
      assert_equal @product.taxons.map(&:id).sort, @taxon_ids.sort
      assert_equal @product.name, "Test Product"
      assert_equal @shipping_method.name, "Test"
      assert_equal @shipping_method.calculator.preferred_amount, 10
      assert_equal @shipping_method.zones.first.company_id, @company.id
      assert_equal @shipping_method.zones.first.members.map(&:zoneable), @countries

    end
  end


  def boarding_attributes
    {
      store_name: "Test Store",
      item_title: "Test Product",
      item_description: "Test description",
      price: "100",
      category: @taxon_ids.join(","),
      quantity: "10",
      company_address_attributes: {
        address: "Poznań, Polska",
        latitude: "52.406374",
        longitude: "16.925168100000064",
      },
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
              country_ids: @countries.map(&:ids).join(",")
            }
          }
        }
      }
    }
  end
end
