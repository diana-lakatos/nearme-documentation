require 'test_helper'

class CreateElbJobTest < ActiveSupport::TestCase
  context '#perform' do
    setup do
      @domain = FactoryGirl.create(:domain)
      @certificate_body = "a"
      @private_key = "b"
      @certificate_chain = ""
    end

    should 'trigger Ballancer update' do
      @domain.update_column(:state, 'preparing_update')
      balancer = stub(:dns_name => nil, :update_certificates! => nil)
      balancer.expects(:update_certificates!)
      NearMe::Balancer.expects(:new).returns(balancer)
      UpdateElbJob.perform(@domain, @certificate_body, @private_key, @certificate_chain)
      assert @domain.elb_secured?
    end

    should 'raise error when something went wrong and show error state' do
      @domain.update_column(:state, 'preparing_update')
      error_text = 'error_text'
      balancer = stub(:errors => error_text)
      balancer.stubs(:update_certificates!).raises(Exception)
      NearMe::Balancer.expects(:new).returns(balancer)
      assert_raises(Exception) {
        UpdateElbJob.perform(@domain, @certificate_body, @private_key, @certificate_chain)
        assert_equal @domain.error_message, error_text
        assert @domain.error_update?
      }
    end
  end
end
