require 'test_helper'

class OrderBuilderTest < ActiveSupport::TestCase
  context '#can_order_by?' do
    should 'return false if order is present and is not asc or desc' do
      assert !Location.can_order_by?(sort: :created_at, order: :undefined)
    end

    should 'return false unless sort present or here is no such column' do
      assert !Location.can_order_by?(order: :desc)
      assert !Location.can_order_by?(sort: :undefined_column, order: :desc)
    end

    should 'return true if all needed params are passed' do
      assert Location.can_order_by?(sort: :created_at, order: :desc)
    end
  end

  context '#build_order' do
    should 'raise exception if params are wrong' do
      assert_raises ArgumentError do
        Location.build_order(sort: :undefined_column, order: :desc)
      end
    end

    should 'build order string if params are right' do
      assert_equal 'locations.created_at DESC', Location.build_order(sort: :created_at, order: :desc)
      assert_equal 'locations.created_at ASC', Location.build_order(sort: :created_at)
    end
  end
end
