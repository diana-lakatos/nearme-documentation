require "test_helper"

class AccessorsTest < ActionDispatch::IntegrationTest

  setup do
    @sample_model_type = FactoryGirl.create(:sample_model_type)
  end

  context 'destroy' do
    setup do
      @custom_attribute = FactoryGirl.create(:custom_attribute, name: 'destroy', target: @sample_model_type)
      @sample_model = FactoryGirl.create(:sample_model, sample_model_type: @sample_model_type)
      @sample_model.apply_custom_attributes
    end

    should 'be really destroyed despite attribute' do
      assert_difference 'SampleModel.count', -1 do
        @sample_model.destroy
      end
    end

    should 'not be allowed to use write accessor' do
      assert_raise NoMethodError do
        @sample_model.destroy = 10
      end
    end

  end

end

