require "test_helper"

class CacheableTest < ActionDispatch::IntegrationTest

  setup do
    @sample_model_type = FactoryGirl.create(:sample_model_type)
    @custom_attribute = FactoryGirl.create(:custom_attribute, name: 'My Attribute', target: @sample_model_type)
    @sample_model = FactoryGirl.create(:sample_model, sample_model_type: @sample_model_type)
    CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array = {}
    CustomAttributes::CustomAttribute::CacheTimestampsHolder.custom_attributes_cache_update_at = {}
  end

  should 'populate cache variable and timestamp' do
    travel_to(Time.zone.now) do
      SampleModel.clear_custom_attributes_cache
      @sample_model.custom_attributes
      assert_equal [@sample_model_type.id], CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'].keys
      assert_equal 1, CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'][@sample_model_type.id].count
      assert_equal [@custom_attribute.name, @custom_attribute.attribute_type, @custom_attribute.default_value, @custom_attribute.public, nil, [], nil, nil], CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'][@sample_model_type.id].first
      assert_equal [@sample_model_type.id], CustomAttributes::CustomAttribute::CacheTimestampsHolder.custom_attributes_cache_update_at['SampleModelType'].keys
      assert_equal Time.zone.now.utc.to_i, CustomAttributes::CustomAttribute::CacheTimestampsHolder.custom_attributes_cache_update_at['SampleModelType'][@sample_model_type.id].to_i
    end
  end

  context 'update cache' do

    setup do
      SampleModel.clear_custom_attributes_cache
      @sample_model.custom_attributes
    end

    should 'see newly created attributes' do
      assert_equal 1, CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'][@sample_model_type.id].count
      @new_custom_attribute = FactoryGirl.create(:custom_attribute, name: 'My Second Attribute', target: @sample_model_type)
      @sample_model.custom_attributes
      assert_equal 1, CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'][@sample_model_type.id].count
      old_time = CustomAttributes::CustomAttribute::CacheTimestampsHolder.custom_attributes_cache_update_at['SampleModelType'][@sample_model_type.id]
      travel_to(Time.zone.now + 10.seconds) do
        SampleModel.clear_custom_attributes_cache
        @sample_model.custom_attributes
        assert_equal ['my_attribute', 'my_second_attribute'], CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'][@sample_model_type.id].map { |arr| arr[0] }.sort
        assert_not_equal old_time, CustomAttributes::CustomAttribute::CacheTimestampsHolder.custom_attributes_cache_update_at['SampleModelType'][@sample_model_type.id]
        assert_equal Time.now.utc, CustomAttributes::CustomAttribute::CacheTimestampsHolder.custom_attributes_cache_update_at['SampleModelType'][@sample_model_type.id]
      end
    end

    should 'see changes done to existing attributes' do
      assert_equal ['my_attribute'], CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'][@sample_model_type.id].map { |arr| arr[0] }.sort
      travel_to(Time.zone.now + 10.seconds) do
        @custom_attribute.update_attribute(:name, 'updated_attr')
        SampleModel.clear_custom_attributes_cache
        @sample_model.custom_attributes
        assert_equal ['updated_attr'], CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'][@sample_model_type.id].map { |arr| arr[0] }.sort
      end
    end

    should 'forget destroyed attribute' do
      assert_equal 1, CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'][@sample_model_type.id].count
      travel_to(Time.zone.now + 10.seconds) do
        @custom_attribute.destroy
        SampleModel.clear_custom_attributes_cache
        @sample_model.custom_attributes
        assert_equal 0, CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array['SampleModelType'][@sample_model_type.id].count
      end
    end

  end

  should 'make only one sql query if cache available' do
    5.times do
      FactoryGirl.create(:sample_model, sample_model_type: @sample_model_type)
    end
    CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array = {}
    CustomAttributes::CustomAttribute::CacheTimestampsHolder.custom_attributes_cache_update_at = {}
    ::CustomAttributes::CustomAttribute::CacheTimestampsHolder.expects(:touch).once
    models = SampleModel.all.load
    models.map(&:properties)
  end


end

