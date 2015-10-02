require 'test_helper'

class ProductFormTest < ActiveSupport::TestCase

  setup do
    PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
    @user = FactoryGirl.create(:user, name: "Firstname Lastname")
    @product = FactoryGirl.create(:base_product, user: @user)
    @zone = FactoryGirl.create(:zone)
  end

  context "boarding form shipping testing" do
    should 'convert shipping dimensions (imperial) to other units of measure' do
      @product_form = ProductForm.new(@product, {})
      @product_form.weight = 101
      @product_form.weight_unit = 'lb'
      @product_form.height = 103
      @product_form.height_unit = 'ft'
      @product_form.width = 102
      @product_form.width_unit = 'ft'
      @product_form.depth = 104
      @product_form.depth_unit = 'ft'

      @product.shippo_enabled = true
      @product_form.unit_of_measure = 'imperial'
      @product_form.save!

      @product.master.reload
      assert_equal 101*16, @product.master.weight
      assert_equal 103*12, @product.master.height
      assert_equal 102*12, @product.master.width
      assert_equal 104*12, @product.master.depth
    end

    should 'convert shipping dimensions (metric) to other units of measure' do
      @product_form = ProductForm.new(@product, {})
      @product_form.weight = 101
      @product_form.weight_unit = 'kg'
      @product_form.height = 103
      @product_form.height_unit = 'cm'
      @product_form.width = 102
      @product_form.width_unit = 'm'
      @product_form.depth = 104
      @product_form.depth_unit = 'cm'

      @product.shippo_enabled = true
      @product_form.unit_of_measure = 'metric'
      @product_form.save!

      @product.master.reload
      assert_equal 3562.67.round, @product.master.weight.round
      assert_equal 40.5512.round, @product.master.height.round
      assert_equal 4015.75.round, @product.master.width.round
      assert_equal 40.94.round, @product.master.depth.round
    end
  end

end

