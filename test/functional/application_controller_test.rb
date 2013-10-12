require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  context '#load_request_context' do

    setup do
      @example_instance_domain = FactoryGirl.create(:domain, :name => 'instance.example.com', :target => FactoryGirl.create(:instance, :name => 'Example Instance', :theme => FactoryGirl.create(:theme)))
      @example_instance = @example_instance_domain.target

      @example_partner_domain = FactoryGirl.create(:domain, :name => 'partner.example.com', :target => FactoryGirl.create(:partner, :name => 'Example Partner', :theme => FactoryGirl.create(:theme)))
      @example_partner = @example_partner_domain.target

      @example_company_domain = FactoryGirl.create(:domain, :name => 'company.example.com', :target => FactoryGirl.create(:company, :theme => FactoryGirl.create(:theme), :instance => FactoryGirl.create(:instance, :name => 'Company Instance')))
      @example_company = @example_company_domain.target
    end

    should 'default instance if domain is unknown' do
      @controller.stubs(:request).returns(mock(:host => 'something.weird.example.com'))
      @controller.send(:load_request_context)
      assert_equal Instance.default_instance, @controller.send(:current_instance)
      assert_equal Instance.default_instance.theme, @controller.send(:current_theme)
    end

    should 'default instance if domain is desksnear.me' do
      @controller.stubs(:request).returns(mock(:host => 'desksnear.me'))
      @controller.send(:load_request_context)
      assert_equal Instance.default_instance, @controller.send(:current_instance)
      assert_equal Instance.default_instance.theme, @controller.send(:current_theme)
    end

    should 'instance linked to domain that matches request.host' do
      @controller.stubs(:request).returns(mock(:host => @example_instance_domain.name))
      @controller.send(:load_request_context)
      assert_equal @example_instance, @controller.send(:current_instance)
      assert_equal @example_instance.theme, @controller.send(:current_theme)
    end

    context 'company white label' do

      setup do
        @controller.stubs(:request).returns(mock(:host => @example_company_domain.name))
      end

      should 'company linked to domain that matches request.host has white label enabled' do
        @example_company.update_attribute(:white_label_enabled, true)
        @controller.send(:load_request_context)
        assert_equal @example_company.instance, @controller.send(:current_instance)
        assert_equal @example_company.theme, @controller.send(:current_theme)
      end

      should 'default instance if company linked to domain that matches request.host has white label disabled' do
        @example_company.update_attribute(:white_label_enabled, false)
        @controller.send(:load_request_context)
        assert_equal Instance.default_instance, @controller.send(:current_instance)
        assert_equal Instance.default_instance.theme, @controller.send(:current_theme)
      end
    end

    context 'partner' do

      setup do
        @controller.stubs(:request).returns(mock(:host => @example_partner_domain.name))
      end

      should 'find current partner' do
        @controller.send(:load_request_context)
        assert_equal @example_partner, @controller.send(:current_partner)
        assert_equal @example_partner.theme, @controller.send(:current_theme)
        assert_equal @example_partner.instance, @controller.send(:current_instance)
      end

    end
  end

end

