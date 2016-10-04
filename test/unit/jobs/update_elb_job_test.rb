require 'test_helper'

class UpdateElbJobTest < ActiveSupport::TestCase
  context '#perform' do
    setup do
      @domain = FactoryGirl.create(:domain)
    end

    should 'trigger Ballancer update' do
      @domain.update_column(:state, 'elb_secured')
      balancer = stub(dns_name: nil, :update_certificates! => nil)
      balancer.expects(:update_certificates!)
      NearMe::Balancer.expects(:new).returns(balancer)
      UpdateElbJob.perform(@domain.id)
      @domain.reload
    end

    should 'raise error when something went wrong and show error state' do
      @domain.update_column(:state, 'elb_secured')
      error_text = 'StandardError'
      balancer = stub(errors: error_text)
      balancer.stubs(:update_certificates!).raises(StandardError)
      NearMe::Balancer.expects(:new).returns(balancer)
      UpdateElbJob.perform(@domain.id)
      @domain.reload
      assert_equal @domain.error_message, error_text
    end
  end
end
