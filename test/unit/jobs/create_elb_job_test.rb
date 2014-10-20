require 'test_helper'

class CreateElbJobTest < ActiveSupport::TestCase
  context '#perform' do
    setup do
      @domain = FactoryGirl.create(:domain)
      @domain.prepare_elb!
      @certificate_body = "a"
      @private_key = "b"
      @certificate_chain = ""
    end

    should 'trigger Ballancer creation on valid and save dns_name' do
      dns_name = 'test-dns-name.com'
      balancer = stub(:dns_name => dns_name, :create! => nil)
      NearMe::Balancer.expects(:new).returns(balancer)
      CreateElbJob.perform(@domain, @certificate_body, @private_key, @certificate_chain)
      assert_equal @domain.dns_name, dns_name
      assert @domain.elb_secured?
    end

    should 'raise error when something went wrong and show error state' do
      error_text = 'error_text'
      balancer = stub(:errors => error_text)
      balancer.stubs(:create!).raises(Exception)
      NearMe::Balancer.expects(:new).returns(balancer)
      assert_raises(Exception) {
        CreateElbJob.perform(@domain, @certificate_body, @private_key, @certificate_chain)
        assert_equal @domain.error_message, error_text
        assert @domain.error?
      }
    end
  end
end
