require 'test_helper'

class InstanceTest < ActiveSupport::TestCase

  should belong_to(:partner)

  context '#find_instance_by_request' do

    setup do
      @desks_instance = FactoryGirl.create(:instance, :name => 'DesksNearMe')
      @pbcenter_instance = FactoryGirl.create(:instance, :name => 'PBCenter')
      @pbcenter_domain = FactoryGirl.create(:domain, :name => 'pbcenter.desksnear.me', :instance => @pbcenter_instance)
    end

    should 'return PBCenter when host is pbcenter.desksnear.me' do
      request = mock(:host => 'pbcenter.desksnear.me')
      assert_equal @pbcenter_instance, Instance.find_for_request(request)
    end

    should 'return W for whoteldesks domain' do
      @w_instance = FactoryGirl.create(:instance, :name => 'W')
      @w_domain = FactoryGirl.create(:domain, :name => 'whoteldesks.com', :instance => @w_instance)
      request = mock(:host => 'whoteldesks.com')
      assert_equal @w_instance, Instance.find_for_request(request)
    end

    should 'return W for whoteldesks domain with www' do
      @w_instance = FactoryGirl.create(:instance, :name => 'W')
      @w_domain = FactoryGirl.create(:domain, :name => 'whoteldesks.com', :instance => @w_instance)
      request = mock(:host => 'www.whoteldesks.com')
      assert_equal @w_instance, Instance.find_for_request(request)
    end

  end

  context "#find_mailer_for" do
    should 'find valid mailer' do
      @instance = Instance.default_instance || FactoryGirl.create(:instance)
      PrepareEmail.for('listing_mailer/share')
      fake_context = stub(action_name: 'share', lookup_context: stub(prefixes: ["listing_mailer"]))
      assert_kind_of EmailTemplate, @instance.find_mailer_for(fake_context)
    end

    should 'raise for invalid mailer' do
      @instance = Instance.default_instance || FactoryGirl.create(:instance)
      fake_context = stub(action_name: 'share', lookup_context: stub(prefixes: ["listing_mailer"]))
      assert_raise(RuntimeError) { @instance.find_mailer_for(fake_context) }
    end
  end

end
