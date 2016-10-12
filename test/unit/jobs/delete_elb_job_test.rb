require 'test_helper'
require 'nearme'

class DeleteElbJobTest < ActiveSupport::TestCase
  context '#perform' do
    should 'call delete!' do
      balancer = stub
      balancer.expects(:delete!).returns(true)
      NearMe::Balancer.expects(:new).with(name: 'name').returns(balancer)
      DeleteElbJob.perform('name')
    end
  end
end
