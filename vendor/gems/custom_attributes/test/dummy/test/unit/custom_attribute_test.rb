require 'test_helper'

class CustomAttributeTest < ActiveSupport::TestCase

  context 'array values' do

    setup do
      @sample_model_type = FactoryGirl.create(:sample_model_type)
      @custom_attribute = FactoryGirl.create(:custom_attribute_array, target: @sample_model_type)
      @sample_model = @sample_model_type.sample_models.build
    end

    should 'be able to submit strings that will be parsed as array, then save and reload array' do
      @sample_model.array = 'One, Two    ,    Three,Four'
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.array
      @sample_model.save!
      @sample_model.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.array
      @sample_model.save!
      @sample_model.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.array
    end

    should 'be able to assign array as array' do
      @sample_model.array = ['One', 'Two', 'Three', 'Four']
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.array
      @sample_model.save!
      @sample_model.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @sample_model.array
    end

    should 'return empty array if nil' do
      @sample_model.array = nil
      assert_equal [], @sample_model.array

    end
  end

  context 'cache' do

  end


end

