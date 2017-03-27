require 'test_helper'

class Instances::InstanceFinderTest < ActiveSupport::TestCase
  test 'find instances by name' do
    instance = FactoryGirl.create(:instance, id: 5011)
    assert_equal 1, Instances::InstanceFinder.get(:hallmark).count
  end
end
