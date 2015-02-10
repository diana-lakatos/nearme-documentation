require 'test_helper'

class VariantTest < ActionView::TestCase
   setup do
     @variant = FactoryGirl.build(:spree_variant)
     @product = FactoryGirl.build(:base_product, user: FactoryGirl.build(:user))
     @variant.product = @product
   end

  context 'saving' do
    should 'save with correct params' do
      @variant.unit_of_measure = 'imperial'
    
      assert @variant.save
    end

    should 'not save without unit of measure' do
      @variant.unit_of_measure = 'invalid'

      assert_not @variant.save
    end

    should 'not save with invalid imperial unit' do
      @variant.unit_of_measure = 'imperial'
      @variant.weight_unit = 'kg'

      assert_not @variant.save
    end

    should 'not save with invalid metric unit' do
      @variant.unit_of_measure = 'metric'
      @variant.weight_unit = 'pound'

      assert_not @variant.save
    end

    should 'save with valid metric unit' do
      @variant.unit_of_measure = 'metric'
      @variant.weight_unit = 'kg'

      assert_not @variant.save
    end
  end

end

