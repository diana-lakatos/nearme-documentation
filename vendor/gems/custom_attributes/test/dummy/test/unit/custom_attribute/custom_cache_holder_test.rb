require 'test_helper'

class CustomAttributes::CustomAttribute::CacheDataHolderTest < ActionView::TestCase

  setup do
    CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array = {}
  end

  should 'return nil if target type does not exists in array' do
    assert_nil CustomAttributes::CustomAttribute::CacheDataHolder.get('a', 1)
  end

  should 'return proper value if exists' do
    CustomAttributes::CustomAttribute::CacheDataHolder.store('a', 1, ['some', 'data'])
    assert_equal ['some', 'data'], CustomAttributes::CustomAttribute::CacheDataHolder.get('a', 1)
  end

  should 'be able to store data if does not exist' do
    CustomAttributes::CustomAttribute::CacheDataHolder.fetch('a', 1) do
      ['some', 'data']
    end
    CustomAttributes::CustomAttribute::CacheDataHolder.fetch('a', 1) do
      ['this', 'should', 'not', 'be', 'invoked', 'again']
    end
    assert_equal ['some', 'data'], CustomAttributes::CustomAttribute::CacheDataHolder.get('a', 1)
  end

  should 'return nil value if does not exists' do
    CustomAttributes::CustomAttribute::CacheDataHolder.store('a', 1, ['some', 'data'])
    assert_nil CustomAttributes::CustomAttribute::CacheDataHolder.get('a', 2)
  end

  should 'return nil if destroyed' do
    CustomAttributes::CustomAttribute::CacheDataHolder.store('a', 1, ['some', 'data'])
    CustomAttributes::CustomAttribute::CacheDataHolder.destroy('a', 1)
    assert_nil CustomAttributes::CustomAttribute::CacheDataHolder.get('a', 1)
  end

  teardown do
    CustomAttributes::CustomAttribute::CacheDataHolder.custom_attributes_as_array = {}
  end


end

