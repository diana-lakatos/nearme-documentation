require 'test_helper'

class DomainTest < ActiveSupport::TestCase

  should belong_to(:instance)

  context '#find_instance_by_request' do

    setup do
      @desks_instance = FactoryGirl.create(:instance, :name => 'DesksNearMe')
      @pbcenter_instance = FactoryGirl.create(:instance, :name => 'PBCenter')
      @pbcenter_domain = FactoryGirl.create(:domain, :name => 'pbcenter.desksnear.me', :instance => @pbcenter_instance)
    end

    should 'return DesksNearMe when no subdomain' do
      request = mock(:subdomain => '', :domain => 'desksnear.me')
      assert_equal @desks_instance, Domain.find_instance_by_request(request)
    end

    should 'return PBCenter when subdomain is pbcenter' do
      request = mock(:subdomain => 'pbcenter', :domain => 'desksnear.me')
      assert_equal @pbcenter_instance, Domain.find_instance_by_request(request)
    end

    should 'return W for whoteldesks domain even if www is before' do
      @w_instance = FactoryGirl.create(:instance, :name => 'W')
      @w_domain = FactoryGirl.create(:domain, :name => 'www.whoteldesks.com', :instance => @w_instance)
      request = mock(:subdomain => '', :domain => 'whoteldesks.com')
      assert_equal @w_instance, Domain.find_instance_by_request(request)
    end

    should 'return W for whoteldesks domain' do
      @w_instance = FactoryGirl.create(:instance, :name => 'W')
      @w_domain = FactoryGirl.create(:domain, :name => 'whoteldesks.com', :instance => @w_instance)
      request = mock(:subdomain => '', :domain => 'whoteldesks.com')
      assert_equal @w_instance, Domain.find_instance_by_request(request)
    end

    should 'return W for whoteldesks domain for any subdomain if * is provided' do
      @w_instance = FactoryGirl.create(:instance, :name => 'W')
      @w_domain = FactoryGirl.create(:domain, :name => '*.whoteldesks.com', :instance => @w_instance)
      request = mock(:subdomain => 'anything', :domain => 'whoteldesks.com')
      assert_equal @w_instance, Domain.find_instance_by_request(request)
    end

  end
end
