require "test_helper"

class TransactableTypeAttributeCacheTest < ActionDispatch::IntegrationTest

  setup do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @transactable_type = FactoryGirl.create(:transactable_type)
    TransactableTypeAttribute.destroy_all
    @transactable_type_attribute = FactoryGirl.create(:transactable_type_attribute, name: 'My Attribute', transactable_type: @transactable_type)
    @transactable = FactoryGirl.create(:transactable, transactable_type: @transactable_type)
    Transactable.transactable_type_attributes_as_array = {}
    Transactable.transactable_type_attributes_cache_update_at = {}
  end

  should 'populate cache variable and timestamp' do
    Timecop.freeze do
      @t = Transactable.last
      raise "nil!" if @t.transactable_type_id.nil?
      assert_equal [@transactable_type.id], Transactable.transactable_type_attributes_as_array.keys
      assert_equal 1, Transactable.transactable_type_attributes_as_array[@transactable_type.id].count
      assert_equal [@transactable_type_attribute.name, @transactable_type_attribute.attribute_type, @transactable_type_attribute.default_value, @transactable_type_attribute.public], Transactable.transactable_type_attributes_as_array[@transactable_type.id].first
      assert_equal [@transactable_type.id], Transactable.transactable_type_attributes_cache_update_at.keys
      assert_equal Time.now.utc, Transactable.transactable_type_attributes_cache_update_at[@transactable_type.id]
    end
  end

  should 'update array in each request' do
    PlatformContext.current = PlatformContext.new(@instance)
    Transactable.first
    assert_equal 1, Transactable.transactable_type_attributes_as_array[@transactable_type.id].count
    @new_transactable_type_attribute = FactoryGirl.create(:transactable_type_attribute, name: 'My Second Attribute', transactable_type: @transactable_type)
    Transactable.first
    assert_equal 1, Transactable.transactable_type_attributes_as_array[@transactable_type.id].count
    old_time = Transactable.transactable_type_attributes_cache_update_at[@transactable_type.id]
    Timecop.travel(Time.zone.now + 10.second)
    Timecop.freeze do
      PlatformContext.current = PlatformContext.new(@instance)
      Transactable.first
      assert_equal 2, Transactable.transactable_type_attributes_as_array[@transactable_type.id].count
      assert_equal ['my_attribute', 'my_second_attribute'], Transactable.transactable_type_attributes_as_array[@transactable_type.id].map { |arr| arr[0] }.sort
      assert_not_equal old_time, Transactable.transactable_type_attributes_cache_update_at[@transactable_type.id]
      assert_equal Time.now.utc, Transactable.transactable_type_attributes_cache_update_at[@transactable_type.id]
    end
    Timecop.return
  end

  should 'make only one sql query if cache available' do
    5.times do
      FactoryGirl.create(:transactable, transactable_type: @transactable_type)
    end
    Transactable.transactable_type_attributes_as_array = {}
    Transactable.transactable_type_attributes_cache_update_at = {}
    TransactableTypeAttribute.stubs(:find_as_array).returns([[@transactable_type_attribute.name, @transactable_type_attribute.attribute_type, @transactable_type_attribute.default_value, @transactable_type_attribute.public]])
    Transactable.all.load
  end


end

