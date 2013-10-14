require 'test_helper'

class PublicControllerTest < ActionController::TestCase

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
      @request.host = 'something.weird.example.com'
      get :index
      assert_equal Instance.default_instance, assigns(:current_instance)
      assert_equal Instance.default_instance.theme, assigns(:current_theme)
    end

    should 'default instance if domain is desksnear.me' do
      @request.host = "desksnear.me"
      get :index
      assert_equal Instance.default_instance, assigns(:current_instance)
      assert_equal Instance.default_instance.theme, assigns(:current_theme)
    end

    should 'instance linked to domain that matches request.host' do
      @request.host = @example_instance_domain.name
      get :index
      assert_equal @example_instance, assigns(:current_instance)
      assert_equal @example_instance.theme, assigns(:current_theme)
    end

    context 'company white label' do

      setup do
        @request.host = @example_company_domain.name
      end

      should 'company linked to domain that matches request.host has white label enabled' do
        @example_company.update_attribute(:white_label_enabled, true)
        get :index
        assert_equal @example_company.instance, assigns(:current_instance)
        assert_equal @example_company.theme, assigns(:current_theme)
      end

      should 'default instance if company linked to domain that matches request.host has white label disabled' do
        @example_company.update_attribute(:white_label_enabled, false)
        get :index
        assert_equal Instance.default_instance, assigns(:current_instance)
        assert_equal Instance.default_instance.theme, assigns(:current_theme)
      end
    end

    context 'partner' do

      setup do
        @request.host = @example_partner_domain.name
      end

      should 'find current partner' do
        get :index
        assert_equal @example_partner, assigns(:current_partner)
        assert_equal @example_partner.theme, assigns(:current_theme)
        assert_equal @example_partner.instance, assigns(:current_instance)
      end

    end
  end
end
