require 'test_helper'

class CreateElbJobTest < ActiveSupport::TestCase
  context '#perform' do
    setup do
      @domain = FactoryGirl.create(:domain, load_balancer_name: 'name')
      @domain.prepare_elb!
      @certificate_body = 'a'
      @private_key = 'b'
      @certificate_chain = ''

      @balancer_options = {
        name: @domain.load_balancer_name,
        certificate_body: @certificate_body,
        private_key: @private_key,
        certificate_chain: @certificate_chain,
        template_name: 'staging'
      }
    end

    should 'trigger Ballancer creation on valid and save dns_name' do
      dns_name = 'test-dns-name.com'
      balancer = stub(dns_name: dns_name, :create! => nil)
      NearMe::Balancer.expects(:new).with(@balancer_options).returns(balancer)
      CreateElbJob.perform(@domain.id, @certificate_body, @private_key, @certificate_chain)
      @domain.reload
      assert_equal @domain.dns_name, dns_name
      assert @domain.elb_secured?
    end

    should 'raise error when something went wrong and show error state' do
      error_text = 'StandardError'
      balancer = stub(errors: error_text)
      balancer.stubs(:create!).raises(StandardError)
      NearMe::Balancer.expects(:new).with(@balancer_options).returns(balancer)
      CreateElbJob.perform(@domain.id, @certificate_body, @private_key, @certificate_chain)
      @domain.reload
      assert_equal @domain.error_message, error_text
      assert @domain.failed?
    end
  end
end
