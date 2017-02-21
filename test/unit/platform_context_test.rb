require 'test_helper'

class PlatformContextTest < ActiveSupport::TestCase
  context 'root_secured? and secured? for root domain' do
    should 'be true when root is secured' do
      PlatformContext.stubs(root_secured: true)
      ctx = PlatformContext.current
      assert ctx.root_secured?
      assert ctx.secured?
    end

    should 'be false when root is not secured' do
      PlatformContext.stubs(root_secured: false)
      ctx = PlatformContext.current
      refute ctx.root_secured?
      refute ctx.secured?
    end
  end

  context 'find_for_request' do
    setup do
      @desks_near_me_domain = FactoryGirl.create(:domain, name: 'desksnearme.com', target: FactoryGirl.create(:instance))
      @company = FactoryGirl.create(:company, instance_id: @desks_near_me_domain.target.id)
      @example_domain = FactoryGirl.create(:domain, name: 'domainexample.com', target: @company, target_type: 'Company')
      @partner_domain = FactoryGirl.create(:domain, name: 'partner.example.com', target: FactoryGirl.create(:partner), target_type: 'Partner')
    end

    should 'be able to find by host name' do
      rq = PlatformContext.new('desksnearme.com')
      assert_equal @desks_near_me_domain, rq.domain
    end

    should 'recognize domain from non-existent subdomains' do
      rq = PlatformContext.new('www.nonsense.desksnearme.com')
      assert_equal @desks_near_me_domain, rq.domain
    end

    should 'be able to bypass non-existent www subdomain' do
      example_www_domain = FactoryGirl.create(:domain, name: 'www.example.co.uk')
      rq = PlatformContext.new('example.co.uk')
      assert_equal example_www_domain, rq.domain
    end

    should 'be able to bypass www in host name' do
      rq = PlatformContext.new('www.desksnearme.com')
      assert_equal @desks_near_me_domain, rq.domain
    end

    should 'recognize secured domain' do
      @desks_near_me_domain.update_column(:secured, true)
      rq = PlatformContext.new('www.desksnearme.com')
      assert rq.secured?
    end

    should 'recognize unsecured domain' do
      @desks_near_me_domain.update_attribute(:secured, false)
      rq = PlatformContext.new('www.desksnearme.com')
      refute rq.secured?
    end
  end

  context 'redirect' do
    setup do
      @desks_near_me_domain = FactoryGirl.create(:domain, name: 'desksnearme.com', target: FactoryGirl.create(:instance))
    end

    should 'not redirect if there is no redirection enabled' do
      rq = PlatformContext.new('desksnearme.com')
      refute rq.should_redirect?
    end

    should 'redirect if domain does not exist' do
      rq = PlatformContext.new('blog.desksnear.me')
      assert rq.should_redirect?
    end

    should 'redirect if redirection is enabled on domain' do
      @desks_near_me_domain.update_attributes redirect_to: 'http://near-me.com', redirect_code: 302
      rq = PlatformContext.new('desksnearme.com')
      assert rq.should_redirect?
    end
  end

  context 'redirect_url' do
    setup do
      @desks_near_me_domain = FactoryGirl.create(:domain, name: 'desksnearme.com', target: FactoryGirl.create(:instance))
    end

    should 'return domain url if subdomain does not exist' do
      rq = PlatformContext.new('blog.desksnearme.com')
      assert_equal @desks_near_me_domain.url, rq.redirect_url
    end

    should 'return valid url if redirection is enabled' do
      @desks_near_me_domain.update_attributes redirect_to: 'http://another-web.com', redirect_code: 302
      rq = PlatformContext.new('desksnearme.com')
      assert_equal 'http://another-web.com', rq.redirect_url
    end

    should 'return near-me url if domain does not exist' do
      rq = PlatformContext.new('fake.domain.net')
      assert_equal PlatformContext::NEAR_ME_REDIRECT_URL, rq.redirect_url
    end
  end

  context 'redirect_code' do
    setup do
      @desks_near_me_domain = FactoryGirl.create(:domain, name: 'desksnearme.com', target: FactoryGirl.create(:instance))
    end

    should 'return default code if domain does not exist' do
      rq = PlatformContext.new('fake.domain.net')
      assert_equal PlatformContext::DEFAULT_REDIRECT_CODE, rq.redirect_code
    end

    should 'return stored redirect code if available' do
      @desks_near_me_domain.update_attributes redirect_to: 'http://another-web.com', redirect_code: 301
      rq = PlatformContext.new('desksnearme.com')
      assert_equal 301, rq.redirect_code
    end

    should 'return default code if domain does not redirect' do
      rq = PlatformContext.new('desksnearme.com')
      assert_equal PlatformContext::DEFAULT_REDIRECT_CODE, rq.redirect_code
    end
  end

  context 'loading request context' do
    setup do
      @example_instance_domain = FactoryGirl.create(:domain, name: 'instance.example.com', target: FactoryGirl.create(:instance, name: 'Example Instance', theme: FactoryGirl.create(:theme)))
      @example_instance = @example_instance_domain.target

      @example_partner_domain = FactoryGirl.create(:domain, name: 'partner.example.com', target: FactoryGirl.create(:partner, name: 'Example Partner', theme: FactoryGirl.create(:theme)))
      @example_partner = @example_partner_domain.target

      @example_company_domain = FactoryGirl.create(:domain, name: 'company.example.com', target: FactoryGirl.create(:company, theme: FactoryGirl.create(:theme), instance: FactoryGirl.create(:instance, name: 'Company Instance')))
      @example_company = @example_company_domain.target
    end

    should 'no instance if domain is unknown' do
      rq = PlatformContext.new('something.weird.com')
      assert_nil rq.instance
      assert_nil rq.theme
      assert_nil rq.platform_context_detail
    end

    should 'First instance if domain is desksnearme.com' do
      FactoryGirl.create(:domain, name: 'desksnearme.com', target: PlatformContext.current.instance)
      rq = PlatformContext.new('desksnearme.com')
      assert_equal PlatformContext.current.instance, rq.instance
      assert_equal PlatformContext.current.instance, rq.platform_context_detail
      assert_equal PlatformContext.current.instance.theme, rq.theme
    end

    should 'instance linked to domain that matches request.host' do
      host = @example_instance_domain.name
      rq = PlatformContext.new(host)
      assert_equal @example_instance, rq.instance
      assert_equal @example_instance.theme, rq.theme
      assert_equal @example_instance, rq.platform_context_detail
    end

    context 'company white label' do
      setup do
        @host = @example_company_domain.name
      end

      should 'company linked to domain that matches request.host has white label enabled' do
        @example_company.update_attribute(:white_label_enabled, true)
        rq = PlatformContext.new(@host)
        assert_equal @example_company.instance, rq.instance
        assert_equal @example_company.theme, rq.theme
        assert_equal @example_company, rq.platform_context_detail
      end

      should 'nil instance if company linked to domain that matches request.host has white label disabled' do
        @example_company.update_attribute(:white_label_enabled, false)
        rq = PlatformContext.new(@host)
        assert_nil rq.instance
        assert_nil rq.theme
        assert_nil rq.platform_context_detail
      end

      should 'company linked to domain that matches request.host without white label enabled but with partner' do
        @partner = FactoryGirl.create(:partner, instance_id: FactoryGirl.create(:instance).id)
        @example_company.update_attributes(white_label_enabled: false)
        @example_company.update_attribute(:partner_id, @partner.id)
        rq = PlatformContext.new(@example_company)
        assert_equal @example_company.partner.instance, rq.instance
        assert_equal @example_company.partner.theme, rq.theme
        assert_equal @partner, rq.platform_context_detail
      end
    end

    context 'partner' do
      setup do
        @host = @example_partner_domain.name
      end

      should 'find current partner' do
        rq = PlatformContext.new(@host)
        assert_equal @example_partner, rq.partner
        assert_equal @example_partner.theme, rq.theme
        assert_equal @example_partner.instance, rq.instance
        assert_equal @example_partner, rq.platform_context_detail
      end
    end
  end

  context 'white_label_company_user?' do
    setup do
      @platform_context = PlatformContext.current
      @company = FactoryGirl.create(:white_label_company)
      @user = @company.creator
      @another_user = FactoryGirl.create(:user)
    end

    should 'be a white label company user if nowhite_label_company' do
      assert @platform_context.white_label_company_user?(@user)
    end

    context 'with white label' do
      setup do
        @platform_context.expects(:white_label_company).returns(@company).at_least_once
      end

      should 'not be whie label company user if he does not belong white label company' do
        assert !@platform_context.white_label_company_user?(@another_user)
      end

      should 'be whie label company user if he belongs to white label company' do
        assert @platform_context.white_label_company_user?(@user)
      end
    end
  end
end
