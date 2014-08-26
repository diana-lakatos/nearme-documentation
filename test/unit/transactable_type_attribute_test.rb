require 'test_helper'

class TransactableTypeAttributeTest < ActiveSupport::TestCase

  context 'array values' do

    setup do
      @instance = FactoryGirl.create(:instance)
      PlatformContext.current = PlatformContext.new
      @tt = FactoryGirl.create(:transactable_type)
      @tta = FactoryGirl.create(:transactable_type_attribute_array, transactable_type: @tt)
      @transactable = FactoryGirl.build(:transactable)
    end

    should 'be able to submit strings that will be parsed as array, then save and reload array' do
      @transactable.array = 'One, Two    ,    Three,Four'
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
      @transactable.save!
      @transactable.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
      @transactable.save!
      @transactable.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
    end

    should 'be able to assign array as array' do
      @transactable.array = ['One', 'Two', 'Three', 'Four']
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
      @transactable.save!
      @transactable.reload
      assert_equal ['One', 'Two', 'Three', 'Four'], @transactable.array
    end

    should 'return empty array if nil' do
      @transactable.array = nil
      assert_equal [], @transactable.array

    end
  end
end

