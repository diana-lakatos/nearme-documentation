require 'test_helper'

class ShippingCategoryFormTest < ActiveSupport::TestCase

  setup do
    PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
    @user = FactoryGirl.create(:user, name: "Firstname Lastname")
    @product = FactoryGirl.create(:base_product, user: @user)
    @shipping_category = Spree::ShippingCategory.new
    @company = FactoryGirl.create(:company)
  end

  context "boarding form shipping testing" do
    should "create shipping category on submit" do
      @shipping_category_form = ShippingCategoryForm.new(@shipping_category, @company)
      params = {'name' => 'name', 'shipping_methods_attributes' => { "0"=>{"name"=>"sdsadasad", "removed"=>"0", "processing_time"=>"0", "calculator_attributes"=>{"preferred_amount"=>"0.00", "id"=>"24"}, "zones_attributes"=>{"0"=>{"name"=>"Default - 7c9a98679439b6f3f6966f2246d1fe13", "kind"=>"state_based", "state_ids"=>"485" }}}}}
      assert @shipping_category_form.shipping_category.new_record?
      assert @shipping_category_form.submit(params)
      refute @shipping_category_form.shipping_category.new_record?
    end

    should "not create shipping category on submit if name missing" do
      @shipping_category_form = ShippingCategoryForm.new(@shipping_category, @company)
      params = {'shipping_methods_attributes' => { "0"=>{"name"=>"sdsadasad", "removed"=>"0", "processing_time"=>"0", "calculator_attributes"=>{"preferred_amount"=>"0.00", "id"=>"24"}, "zones_attributes"=>{"0"=>{"name"=>"Default - 7c9a98679439b6f3f6966f2246d1fe13", "kind"=>"state_based", "state_ids"=>"485" }}}}}
      assert @shipping_category_form.shipping_category.new_record?
      refute @shipping_category_form.submit(params)
      assert @shipping_category_form.shipping_category.new_record?
    end

    should "not create shipping category on submit if shipping_method param missing" do
      @shipping_category_form = ShippingCategoryForm.new(@shipping_category, @company)
      params = {'shipping_methods_attributes' => { "0"=>{"name"=>"sdsadasad", "removed"=>"0", "processing_time"=>"0", "calculator_attributes"=>{"preferred_amount"=>"0.00", "id"=>"24"}, "zones_attributes"=>{"0"=>{"name"=>"Default - 7c9a98679439b6f3f6966f2246d1fe13", "kind"=>"state_based" }}}}}
      assert @shipping_category_form.shipping_category.new_record?
      refute @shipping_category_form.submit(params)
      assert @shipping_category_form.shipping_category.new_record?
    end
  end

end

