require 'test_helper'

class Controller::RequestContextTest < ActiveSupport::TestCase

  context 'find_for_request' do

    setup do
      @desks_near_me_domain = FactoryGirl.create(:domain, :name => 'desksnearme.com', :target => FactoryGirl.create(:instance))
      @company = FactoryGirl.create(:company)
      @example_domain = FactoryGirl.create(:domain, :name => 'domainexample.com', :target => @company, :target_type => 'Company')
      @partner_domain = FactoryGirl.create(:domain, :name => 'partner.example.com', :target => FactoryGirl.create(:partner), :target_type => 'Partner')
      @request = mock()
    end

    should 'be able to find by host name' do
      @request.stubs(:host).returns('desksnearme.com')
      rq = Controller::RequestContext.new(@request)
      assert_equal @desks_near_me_domain, rq.domain
    end

    should 'be able to bypass www in host name' do
      @request.stubs(:host).returns('www.desksnearme.com')
      rq = Controller::RequestContext.new(@request)
      assert_equal @desks_near_me_domain, rq.domain
    end

  end

  context 'loading request context' do

    setup do
      @example_instance_domain = FactoryGirl.create(:domain, :name => 'instance.example.com', :target => FactoryGirl.create(:instance, :name => 'Example Instance', :theme => FactoryGirl.create(:theme)))
      @example_instance = @example_instance_domain.target

      @example_partner_domain = FactoryGirl.create(:domain, :name => 'partner.example.com', :target => FactoryGirl.create(:partner, :name => 'Example Partner', :theme => FactoryGirl.create(:theme)))
      @example_partner = @example_partner_domain.target

      @example_company_domain = FactoryGirl.create(:domain, :name => 'company.example.com', :target => FactoryGirl.create(:company, :theme => FactoryGirl.create(:theme), :instance => FactoryGirl.create(:instance, :name => 'Company Instance')))
      @example_company = @example_company_domain.target
    end

    should 'default instance if domain is unknown' do
      request = mock(:host => 'something.weird.example.com')
      rq = Controller::RequestContext.new(request)
      assert_equal Instance.default_instance, rq.instance
      assert_equal Instance.default_instance.theme, rq.theme
    end

    should 'default instance if domain is desksnear.me' do
      request = mock(:host => "desksnear.me")
      rq = Controller::RequestContext.new(request)
      assert_equal Instance.default_instance, rq.instance
      assert_equal Instance.default_instance.theme, rq.theme
    end

    should 'instance linked to domain that matches request.host' do
      request = mock(:host => @example_instance_domain.name)
      rq = Controller::RequestContext.new(request)
      assert_equal @example_instance, rq.instance
      assert_equal @example_instance.theme, rq.theme
    end

    context 'company white label' do

      setup do
        @request = mock(:host => @example_company_domain.name)
      end

      should 'company linked to domain that matches request.host has white label enabled' do
        @example_company.update_attribute(:white_label_enabled, true)
        rq = Controller::RequestContext.new(@request)
        assert_equal @example_company.instance, rq.instance
        assert_equal @example_company.theme, rq.theme
      end

      should 'default instance if company linked to domain that matches request.host has white label disabled' do
        @example_company.update_attribute(:white_label_enabled, false)
        rq = Controller::RequestContext.new(@request)
        assert_equal Instance.default_instance, rq.instance
        assert_equal Instance.default_instance.theme, rq.theme
      end
    end

    context 'partner' do

      setup do
        @request = mock(:host => @example_partner_domain.name)
      end

      should 'find current partner' do
        rq = Controller::RequestContext.new(@request)
        assert_equal @example_partner, rq.partner
        assert_equal @example_partner.theme, rq.theme
        assert_equal @example_partner.instance, rq.instance
      end

    end
  end

  context 'white_label_company_user?' do

    setup do
      @request_context = Controller::RequestContext.new
      @company = FactoryGirl.create(:white_label_company)
      @user = FactoryGirl.create(:user, companies: [@company])
      @another_user = FactoryGirl.create(:user)
    end

    should 'be a white label company user if nowhite_label_company' do
      assert @request_context.white_label_company_user?(@user)
    end

    context 'with white label' do
      setup do
        @request_context.expects(:white_label_company).returns(@company).at_least_once
      end

      should 'not be whie label company user if he does not belong white label company' do
        assert !@request_context.white_label_company_user?(@another_user)
      end

      should 'be whie label company user if he belongs to white label company' do
        assert @request_context.white_label_company_user?(@user)
      end
    end

  end
end
