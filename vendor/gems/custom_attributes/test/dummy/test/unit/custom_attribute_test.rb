require 'test_helper'

class CustomAttributeTest < ActiveSupport::TestCase

  setup do
    @sample_model_type = FactoryGirl.create(:sample_model_type)
  end

  context 'array values' do

    setup do
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

  context 'valid values' do
    setup do
      @custom_attribute = FactoryGirl.create(:custom_attribute, target: @sample_model_type, valid_values: ['One', 'Two', 'ąĘĆŹ'], name: 'attr')
      @sample_model = @sample_model_type.sample_models.build
    end

    should 'accept all upper cases' do
      @sample_model.attr = 'ONE'
      assert @sample_model.valid?
    end

    should 'accept all lower cases in validation' do
      @sample_model.attr = 'one'
      assert @sample_model.valid?
    end

    should 'correctly deal with case sensitivity for accents' do
      @sample_model.attr = 'ąęćź'
      assert @sample_model.valid?, @sample_model.errors.full_messages.inspect
    end

    should 'not ignore vlidation completely' do
      @sample_model.attr = 'three'
      refute @sample_model.valid?
    end

    should 'not allow nil' do
      @sample_model.attr = nil
      refute @sample_model.valid?
    end

  end

end

