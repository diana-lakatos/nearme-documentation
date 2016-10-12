require 'test_helper'

class DimensionsTemplateTest < ActiveSupport::TestCase
  setup do
    @dimensions_template = FactoryGirl.build(:dimensions_template)
  end

  context 'saving' do
    should 'save with correct params' do
      @dimensions_template.unit_of_measure = 'imperial'
      assert @dimensions_template.save
    end

    should 'not save without unit of measure' do
      @dimensions_template.unit_of_measure = 'invalid'

      assert_not @dimensions_template.save
    end

    should 'not save with invalid imperial unit' do
      @dimensions_template.unit_of_measure = 'imperial'
      @dimensions_template.weight_unit = 'kg'

      assert_not @dimensions_template.save
    end

    should 'not save with invalid metric unit' do
      @dimensions_template.unit_of_measure = 'metric'
      @dimensions_template.weight_unit = 'pound'

      assert_not @dimensions_template.save
    end

    should 'save with valid metric unit' do
      @dimensions_template.unit_of_measure = 'metric'
      @dimensions_template.weight_unit = 'kg'

      assert_not @dimensions_template.save
    end
  end
end
