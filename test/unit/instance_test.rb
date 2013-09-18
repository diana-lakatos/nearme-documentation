require 'test_helper'

class InstanceTest < ActiveSupport::TestCase

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
end
